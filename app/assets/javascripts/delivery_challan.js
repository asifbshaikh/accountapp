$(document).ready(function(){

	$('#delivery_challans').dataTable({
		sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
		sPaginationType: "full_numbers",
		iDisplayLength:50,
		bFilter: true,
		bProcessing: true,
		bServerSide: true,
		sAjaxSource: $('#delivery_challans').data('source')   
	})



	// Batch selection 
	$(".dc-batch-select").live('change', function(){
		var index = $(this).attr('data-index');
		var unit = $(this).attr('data-unit');
		var quantity = $(".dc-line #row"+index+" .dc-batch-select option:selected").attr('data-available-quantity');
    if(quantity !='' && quantity > 0 ){
		$(".dc-line #row"+index+" #dcqty-notif"+index+" ").html("Available qty "+quantity+" "+unit);
	  }
	});


	
	
	// warehouse select 
	$("#delivery_challan_warehouse_id").change(function(){
		var index=0
		var warehouseId = $(this).val();
		console.log(warehouseId)
	  $("table#delivery_challan_line_items tbody tr").each(function(){
	  	var productType=$(".dc-line #row"+index).attr('data-product-type'); 
			var product_id = $(".dc-line #row"+index+" #product_quantity").attr('data-productId'); 
	 			// console.log(product_id)
	  	var quantity_hash=jQuery.parseJSON($(".dc-line #row"+index+" .deliver-quantity ").attr('data-available-quantity'));
	  	var batch_enable = $(".dc-line #row"+index+" #product_quantity").attr('data-batch-enable'); 
	  	var quantity = quantity_hash[warehouseId]
	  	 console.log("batch is"+ batch_enable+ "and quantity is"+ quantity)
	  	
	  	if(warehouseId == null || warehouseId == ''){
	     alert("Please select warehouse.");
	   }else if(batch_enable == 'true'){
	       $(".dc-line #row"+index+" #dcqty-notif"+index+" ").remove();
	       $(".dc-line #row"+index+" .dc-batch-details").remove();
        $('.avlstk').html('<div class="loader text-center" style="display:inline;"><img src="/assets/ajax-loader.gif"></div>');
        $.ajax({ 
	       data: {index: index, product_id: product_id, warehouse_id: warehouseId},
	       url: "/delivery_challans/get_product_batches"
	     });
  	  }else{
  	  	if(productType=="false"){
  			  $("#dcqty-notif"+index+" ").html("<i style='color:red;' id='dcqty-notif"+index+"'>Not Applicable.</i>");
  	  	}else if(quantity > 0){
	  		 $("#dcqty-notif"+index+" ").html("<i style='color:green;' id='dcqty-notif"+index+"'>Available qty "+quantity+"</i>");
	  		 $("#qty_delivered_"+index+" ").attr("disabled", false);
	  	  }else{
	  		$("#dcqty-notif"+index+" ").html("<i style='color:red;' id='dcqty-notif"+index+"'>Stock not available.</i>");
	  	  $("#qty_delivered_"+index+" ").attr("disabled", true);
	  	  }
			}

			index++;
     });
		 
});

// warehouse select 
	$("select#delivery_challan_warehouse_id").each(function(){
		var index=0
		var warehouseId = $(this).val();
		console.log(warehouseId)
	  $("table#delivery_challan_line_items tbody tr").each(function(){
			var productType=$(".dc-line #row"+index).attr('data-product-type'); 
			var product_id = $(".dc-line #row"+index+" #product_quantity").attr('data-productId'); 
	 			console.log("product type :"+productType);
	  	var quantity_hash=jQuery.parseJSON($(".dc-line #row"+index+" .deliver-quantity ").attr('data-available-quantity'));
	  	var batch_enable = $(".dc-line #row"+index+" #product_quantity").attr('data-batch-enable'); 
	  	var quantity = quantity_hash[warehouseId]
	  	 console.log("batch is"+ batch_enable+ "and quantity is"+ quantity)

	  	if(warehouseId == null || warehouseId == ''){
	     alert("Please select warehouse.");
	   }else if(batch_enable == 'true'){
	  	  $(".dc-line #row"+index+" #dcqty-notif"+index+" ").remove();
	      $(".dc-line #row"+index+" .dc-batch-details").remove();
        $('.avlstk').html('<div class="loader text-center" style="display:inline;"><img src="/assets/ajax-loader.gif"></div>');
        $.ajax({ 
	       data: {index: index, product_id: product_id, warehouse_id: warehouseId},
	       url: "/delivery_challans/get_product_batches"
	     });
  	  }else{
  	  	if(productType=="false"){
  			  $("#dcqty-notif"+index+" ").html("<i style='color:red;' id='dcqty-notif"+index+"'>Not Applicable.</i>");
  	  	}else if(quantity > 0){
	  		 $("#dcqty-notif"+index+" ").html("<i style='color:green;' id='dcqty-notif"+index+"'>Available qty "+quantity+"</i>");
	  	  	$("#qty_delivered_"+index+" ").attr("disabled", false);
	  	  }else{
	  		$("#dcqty-notif"+index+" ").html("<i style='color:red;' id='dcqty-notif"+index+"'>Stock not available.</i>");
	  	 	$("#qty_delivered_"+index+" ").attr("disabled", true);
	  	  }
			}

			index++;
     });
		 
});


		 $('table#delivery_challan_line_items input:text').live('keyup', function(e){
      var index= $(this).attr('data-index');
      var warehouseId = $("#delivery_challan_warehouse_id").val();
     console.log(warehouseId)
	    var sales_order_qty = $(".dc-line #row"+index+" .soqty_"+index+" ").attr('data-soquantity'); 
     	var quantity_hash=jQuery.parseJSON($(".dc-line #row"+index+" .deliver-quantity ").attr('data-available-quantity'));
	  	var batch_enable = $(".dc-line #row"+index+" #product_quantity").attr('data-batch-enable'); 
	  	var stock = quantity_hash[warehouseId]

     if ($('table#delivery_challan_line_items tbody tr:eq(' + index + ') #qty_delivered_'+index+' ').val()){
			var delivered_qty = parseFloat($('table#delivery_challan_line_items tbody tr:eq(' + index + ') #qty_delivered_'+index+' ').val());
				 if(delivered_qty > sales_order_qty){
				  alert("Quantity should not greater than sales order quantity");
				  $('table#delivery_challan_line_items tbody tr:eq(' + index + ') #qty_delivered_'+index+' ').val( ' ');
				 }else if(batch_enable=='true'){

				 }else{
				 	if(delivered_qty > stock){
				 	alert("Quantity should not greater than available stock");
				  $('table#delivery_challan_line_items tbody tr:eq(' + index + ') #qty_delivered_'+index+' ').val( ' ');
				 	}
				 }
			}
		index++;
		  e.preventDefault(); 
   	});


});

	