$(document).ready(function(){

	var productTable= $('#products-table').dataTable({
		sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
		iDisplayLength:50,
		bFilter: true,
		bProcessing: true,
		bServerSide: true,
    aoColumns:
        [
          {  "sClass": "col-xs-2" },
          {  "sClass": "col-xs-2" },
          {  "sClass": "col-xs-1" },
          {  "sClass": "col-xs-1" },
          {  "sClass": "col-xs-1" },
          {  "sClass": "col-xs-2" },
          {  "sClass": "col-xs-2" },
          {  "sClass": "col-xs-1" }
        ],
		sAjaxSource: $('#products-table').data('source')
	});

  var stockIssueTable = $('#stock-issue').dataTable({
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
        sAjaxSource: $('#stock-issue').data('source')
      });
// script for toggling information form in product new screen

  if($("#sales").is(":checked")){
    $('.sales-info').show();
  }else{
    $('.sales-info').hide();
  }

  if($("#purchase-sec").is(":checked")){
    $('.purchase-info').show();
  }else{
    $('.purchase-info').hide();
  }

  if($("#product_inventory_1").is(":checked")){
    $('#sales_opening_inventory').show();
    $('#purchase_opening_inventory').show();
  }

  $('#sales').live('click', function(){
    if($("#sales").is(":checked")){
      $('.sales-info').show();
    }else{
      $('.sales-info').hide();
    }
  });

  $('#purchase-sec').live('click', function(){
    if($("#purchase-sec").is(":checked")){
      $('.purchase-info').show();
    }else{
      $('.purchase-info').hide();
    }
  });

	$("#product-inventory-yes").live('click', function(){
	    $('#sales_opening_inventory').show();
	    $('#purchase_opening_inventory').show();
	});

	$("#product-inventory-no").live('click', function(){
	    $('#sales_opening_inventory').hide();
	    $('#purchase_opening_inventory').hide();
	});

	// flush opening stock details on batch enabled/disabled
	var prevElement = "product-batch-enable-no";
	  $("#product-batch-enable-yes, #product-batch-enable-no").click(function(){
	    if(prevElement != $(this).attr('id')){
	      $('.warehouse-detail').remove();
	      $("#opening-stock").val('');
	    }
	    prevElement = $(this).attr('id');
	  });

	  $("#product-batch-enable-no").click(function(){
	  	$("#opening-stock").attr('data-target', '#modal-warehouse')
	  });

	  $("#product-batch-enable-yes").click(function(){
	  	$("#opening-stock").attr('data-target', '#modal-batch')
	  });

	$('.mfd_date').live('focus', function () {
	  // $("#product_product_batches_attributes_"+ $(this).attr('data-index') +"_manufacture_date").datepicker();
	  $(this).datepicker();
	});

	$('.exp_date').live('focus', function () {
	  // $("#product_product_batches_attributes_"+ $(this).attr('data-index') +"_expiry_date").datepicker();
	  $(this).datepicker();
	});

/*
  //code for ajax supported tabs in products index
  $('#myTab a[href="#profile"]').on('shown.bs.tab', function (e) {
    alert(e.target) // activated tab
    alert(e.relatedTarget) // previous tab
  });
*/
  //Variables for datatables will null assignments
  // var stockIssueTable = null;
  var stockReceiptTable = null;
  var stockTransferTable = null;
  var stockWastageTable = null;

  //Code for ajax supported tabs.
  $('#invTabs a').on('shown.bs.tab', function (e) {
    var target = $(e.target).attr('href');// activated tab
    console.log("target= "+ target);
    if(target == '#stock-receipt-tab'){
      showStockReceiptTable();
    }else if(target == '#stock-transfer-tab'){
      showStockTransferTable();
    }else if(target == '#stock-wastage-tab'){
      showStockWastageTable();
    }else if(target == '#stock-return-tab'){
      showStockReturnTable();
    }else{
      // productTable.fnDraw();
    }
  });

  function showStockIssueTable(){
    if(stockIssueTable === null){
      //if the table is null then its first load. Initialize table and show
      stockIssueTable = $('#stock-issue').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#stock-issue').data('source')
      });
    }else{
      //incase the table is already initialized then only reload data.
      // stockIssueTable.fnDraw();
    }
  }
3
  function showStockReceiptTable(){
    if(stockReceiptTable === null){
      stockReceiptTable =  $('#stock-receipt').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#stock-receipt').data('source')
      });
    }else{
      // stockReceiptTable.fnDraw();
    }
  }

  function showStockTransferTable(){
    if(stockTransferTable === null){
      stockTransferTable = $('#stock-transfer').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#stock-transfer').data('source')
      });
    }else{
      // stockTransferTable.fnDraw();
    }
  }

  function showStockWastageTable(){
    if(stockWastageTable === null){
      stockWastageTable = $('#stock-wastage').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#stock-wastage').data('source')
      });
    }else{
      // stockWastageTable.fnDraw();
    }
  }

});
