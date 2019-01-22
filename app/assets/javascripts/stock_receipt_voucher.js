$(document).ready(function(){
	$('#stock-receipt').dataTable({
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
		sAjaxSource: $('#stock-receipt').data('source') 
	})

	$(".receipt-quantity").live('change', function(){
	  var index = $(this).attr("data-index");
	  var product_id = $(this).val();
	  var batch_enable = $(".receipt-line #row"+index+" .receipt-quantity option:selected").attr('data-batch_enable');
	  $(".receipt-line #row"+index+" td:eq(0) .receipt-batch-details").remove();
	  
	  if(batch_enable=='true'){
	  	$(this).after('<div class="loader text-center" style="display:inline;"><img src="/assets/ajax-loader.gif"></div>');
		  $.ajax({
		    data: {index: index, product_id: product_id },
		    url: "/stock_receipt_vouchers/batch_number_details"
		  });
		}else{
			$(".receipt-line #row"+index+" td:eq(0) .receipt-batch-details").remove();
		}
	});
});