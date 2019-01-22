$(document).ready(function(){
  $('#stock-transfer').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    iDisplayLength:50,
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    aoColumns: 
        [
          null,
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          null
        ],
    sAjaxSource: $('#stock-transfer').data('source') 
  })

  $(".transfer-batch-select").live('change', function(){
    var index = $(this).attr('data-index');
    var unit = $(this).attr('data-unit');
    var quantity = $(".transfer-line #row"+index+" select.transfer-batch-select option:selected").attr('data-quantity');
    if(quantity !='' && quantity > 0 ){
    	$(".transfer-line #row"+index+" #qty-notif").html("Available qty "+quantity+" "+unit);
      $(".transfer-line #row"+index+" #quantity").val(quantity);
      $(quantity).appendTo(".transfer-line #row"+index+" td:eq(1)");
    }
  });

  $("#warehouseSelect").change(function() {
    
    var warehouse_id = $("#warehouseSelect").val();
    $.ajax({
      type: 'GET',
      url : "/stock_transfer_vouchers/warehouse_wise_product?warehouse_id="+warehouse_id,
    });

  });

  $(".transfer-quantity-select").live('change', function(){
    var index = $(this).attr('data-index');
    var product_id = $(this).val();
    var warehouse_id = $("#stock_transfer_voucher_warehouse_id").val();
    var batch_enable = $(".transfer-line #row"+index+" select#warehouse_product option:selected").attr('data-batch_enable');
    var quantity = jQuery.parseJSON($(".transfer-line #row"+index+" select.transfer-quantity-select option:selected").attr('data-quantity'));
    $(".transfer-line #row"+index+" #qty-notif").remove();
    $(".transfer-line #row"+index+" .transfer-batch-details").remove();

    if(warehouse_id == null || warehouse_id == '' && batch_enable == 'true'){
      alert("Please select warehouse.");
    }else if(batch_enable == 'false'){
      $(".transfer-line #row"+index+" .transfer-batch-details").remove();
      $(".transfer-line #row"+index+" #quantity").removeAttr('readonly');
      if(quantity[warehouse_id]==null || quantity[warehouse_id]<=0){
      	$(this).after("<i style='color:red;' id='qty-notif'>Stock not available.</i>");
      }else{
      	$(this).after("<i style='color:green;' id='qty-notif'>Available qty "+quantity[warehouse_id]+"</i>");
      }
    }else if(batch_enable == 'true'){
    	$(this).after('<div class="loader text-center" style="display:inline;"><img src="/assets/ajax-loader.gif"></div>');
      $.ajax({
        data: {index: index, product_id: product_id, warehouse_id: warehouse_id},
        url: "/stock_transfer_vouchers/get_product_batches"
      });
    }
  });

  $("select.transfer-quantity-select").each(function(i, element){
    var index = $(element).attr('data-index');
    var batch_enable = $(".transfer-line #row"+index+" select#warehouse_product option:selected").attr('data-batch_enable');

    if(batch_enable == 'false'){
      $(".transfer-line #row"+index+" #qty-notif").remove();
      var warehouse_id = $("select#stock_transfer_voucher_warehouse_id").val();
      var quantity_hash=jQuery.parseJSON($(".transfer-line #row"+index+" select.transfer-quantity-select option:selected").attr('data-quantity'));
      if(quantity_hash[warehouse_id]==null || quantity_hash[warehouse_id]<=0){
        $(element).after("<i style='color:red;' id='qty-notif'>Stock not available.</i>");
      }else{
        $(element).after("<i style='color:green;' id='qty-notif'>Available qty "+quantity_hash[warehouse_id]+"</i>");
      }
    }
  });

  $("#stock_transfer_voucher_warehouse_id").change(function(){
    $("select.stv-product").each(function(i, element){
      var index = $(element).attr('data-index');
      var batch_enable = $(".transfer-line #row"+index+" select#warehouse_product option:selected").attr('data-batch_enable');

      if(batch_enable == 'true'){
        $(".transfer-line #row"+index+" select#warehouse_product").val('');
        $(".transfer-line #row"+index+" .transfer-batch-details").remove();
        $(".transfer-line #row"+index+" .stv-quantity").val('');
      }else{
      	$(".transfer-line #row"+index+" #qty-notif").remove();
	    	var warehouse_id = $("select#stock_transfer_voucher_warehouse_id").val();
	    	var quantity_hash=jQuery.parseJSON($(".transfer-line #row"+index+" select.transfer-quantity-select option:selected").attr('data-quantity'));
        if(quantity_hash !=null){
      		if(quantity_hash[warehouse_id]==null || quantity_hash[warehouse_id]<=0){
      			$(element).after("<i style='color:red;' id='qty-notif'>Stock not available.</i>");
      		}else{
      	  	$(element).after("<i style='color:green;' id='qty-notif'>Available qty "+quantity_hash[warehouse_id]+"</i>");
      	  }
        }
	    }
    });
  });
});