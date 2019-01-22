$(document).ready(function(){
	// $('#stock-issue').dataTable({
	// 	sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
	// 	sPaginationType: "full_numbers",
	// 	iDisplayLength:50,
	// 	bFilter: true,
	// 	bProcessing: true,
	// 	bServerSide: true,
	// 	sAjaxSource: $('#stock-issue').data('source')   
	// })

	$(".issue-batch-select").live('change', function(){
		var index = $(this).attr('data-index');
		var unit = $(this).attr('data-unit');
		var quantity = $(".issue-line #row"+index+" .issue-batch-select option:selected").attr('data-available_quantity');
		$(".issue-line #row"+index+" #qty-notif").html("Available qty "+quantity+" "+unit);
	});
	$(".issue-quantity").live('change', function(){
	  var index = $(this).attr('data-index');
	  var product_id = $(this).val();
	  var warehouse_id = $("#stock_issue_voucher_warehouse_id").val();
	  var batch_enable = $(".issue-line #row"+index+" #product_quantity option:selected").attr('data-batch_enable');
	  var quantity = jQuery.parseJSON($(".issue-line #row"+index+" #product_quantity option:selected").attr('data-available_quantity'));
	  $(".issue-line #row"+index+" #qty-notif").remove();
    $(".issue-line #row"+index+" .issue-batch-details").remove();
	  
	  if(warehouse_id == null || warehouse_id == ''){
	    alert("Please select warehouse.");
	  }else if(batch_enable == 'false'){
	  	if(quantity[warehouse_id]==null || quantity[warehouse_id]<=0){
	  		$(this).after("<i style='color:red;' id='qty-notif'>Stock not available.</i>");
	  	}else{
	    	$(this).after("<i style='color:green;' id='qty-notif'>Available qty "+quantity[warehouse_id]+"</i>");
	    }
	  }else if(batch_enable == 'true'){
  		$(this).after('<div class="loader text-center" style="display:inline;"><img src="/assets/ajax-loader.gif"></div>');
	    $.ajax({
	      data: {index: index, product_id: product_id, warehouse_id: warehouse_id},
	      url: "/stock_issue_vouchers/get_product_batches"
	    });
	  }
	});
	

	$("select.siv-product").each(function(i, element){
    var index = $(element).attr('data-index');
    var batch_enable = $(".issue-line #row"+index+" #product_quantity option:selected").attr('data-batch_enable'); 
    // alert(batch_enable);
    if(batch_enable == 'false'){
    	$(".issue-line #row"+index+" #qty-notif").remove();
    	var warehouse_id = $("select#stock_issue_voucher_warehouse_id").val();
    	var quantity_hash=jQuery.parseJSON($(".issue-line #row"+index+" select.issue-quantity option:selected").attr('data-available_quantity'));
  		if(quantity_hash[warehouse_id]==null || quantity_hash[warehouse_id]<=0){
  			$(element).after("<i style='color:red;' id='qty-notif'>Stock not available.</i>");
  		}else{
  	  	$(element).after("<i style='color:green;' id='qty-notif'>Available qty "+quantity_hash[warehouse_id]+"</i>");
  	  }
    }
	});

	$("#stock_issue_voucher_warehouse_id").change(function(){
	  $("select.siv-product").each(function(i, element){
	    var index = $(element).attr('data-index');
	    var batch_enable = $(".issue-line #row"+index+" #product_quantity option:selected").attr('data-batch_enable'); 
	    // alert(batch_enable);
	    if(batch_enable == 'true'){
	      $(".issue-line #row"+index+" #product_quantity").val('');
	      $(".issue-line #row"+index+" .issue-batch-details").remove();
	      $(".issue-line #row"+index+" .siv-quantity").val('');
	    }else{
      	$(".issue-line #row"+index+" #qty-notif").remove();
	    	var warehouse_id = $("select#stock_issue_voucher_warehouse_id").val();
	    	var quantity_hash=jQuery.parseJSON($(".issue-line #row"+index+" select.issue-quantity option:selected").attr('data-available_quantity'));
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