$(document).ready(function(){
	$('#stock-wastage').dataTable({
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
          null
        ],
		sAjaxSource: $('#stock-wastage').data('source') 
	})

	$(".wastage-batch-select").live('change', function(){
	  var index = $(this).attr('data-index');
	  var unit = $(this).attr('data-unit');
	  var quantity = $(".wastage-line #row"+index+" select.wastage-batch-select option:selected").attr('data-quantity');
	  if(quantity !='' && quantity > 0 ){
	  	$(".wastage-line #row"+index+" #qty-notif").html("Available qty "+quantity+" "+unit);
	  }
	});

	$(".wastage-quantity-select").live('change', function(){
	  var index = $(this).attr('data-index');
	  var product_id = $(this).val();
	  var warehouse_id = $("#stock_wastage_voucher_warehouse_id").val();
	  var batch_enable = $(".wastage-line #row"+index+" #product_quantity option:selected").attr('data-batch_enable');
	  var quantity_hash = jQuery.parseJSON($(".wastage-line #row"+index+" select.wastage-quantity-select option:selected").attr('data-quantity'));
	  $(".wastage-line #row"+index+" .wastage-batch-details").remove();
	  $(".wastage-line #row"+index+" #qty-notif").remove();
	  
	  if(warehouse_id == null || warehouse_id == ''){
	    alert("Please select warehouse.");
	  }else if(batch_enable == 'false'){
	  	if(quantity_hash[warehouse_id]==null || quantity_hash[warehouse_id]<=0){
	  		$(this).after("<i style='color:red;' id='qty-notif'>Stock not available.</i>");
	  	}else{
	    	$(this).after("<i style='color:green;' id='qty-notif'>Available qty "+quantity_hash[warehouse_id]+"</i>");
	    }
	  }else if(batch_enable == 'true'){
	  	$(this).after('<div class="loader text-center" style="display:inline;"><img src="/assets/ajax-loader.gif"></div>');
	    $.ajax({
	      data: {index: index, product_id: product_id, warehouse_id: warehouse_id},
	      url: "/stock_wastage_vouchers/get_product_batches"
	    });
	  }
	});

  $("select.wastage-quantity-select").each(function(i, element){
    var index = $(element).attr('data-index');
    var batch_enable = $(".wastage-line #row"+index+" #product_quantity option:selected").attr('data-batch_enable'); 
    if(batch_enable == 'false'){
    	var warehouse_id = $("select#stock_wastage_voucher_warehouse_id").val();
    	var quantity_hash=jQuery.parseJSON($(".wastage-line #row"+index+" select.wastage-quantity-select option:selected").attr('data-quantity'));
  		if(quantity_hash[warehouse_id]==null || quantity_hash[warehouse_id]<=0){
  			$(element).after("<i style='color:red;' id='qty-notif'>Stock not available.</i>");
  		}else{
  	  	$(element).after("<i style='color:green;' id='qty-notif'>Available qty "+quantity_hash[warehouse_id]+"</i>");
  	  }
    }
  });

	$("#stock_wastage_voucher_warehouse_id").change(function(){
	  $("select.swv-product").each(function(i, element){
	    var index = $(element).attr('data-index');
	  	$(".wastage-line #row"+index+" #qty-notif").remove();
	    var batch_enable = $(".wastage-line #row"+index+" #product_quantity option:selected").attr('data-batch_enable'); 
	    if(batch_enable == 'true'){
	      $(".wastage-line #row"+index+" .wastage-quantity-select").val('');
	      $(".wastage-line #row"+index+" .wastage-batch-details").remove();
	      $(".wastage-line #row"+index+" .swv-quantity").val('');
	    }else{
	    	var warehouse_id = $("select#stock_wastage_voucher_warehouse_id").val();
	    	var quantity_hash=jQuery.parseJSON($(".wastage-line #row"+index+" select.wastage-quantity-select option:selected").attr('data-quantity'));
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