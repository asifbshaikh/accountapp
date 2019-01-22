$(document).ready(function(){


  var completedProj = null;

  var currentPrj = $('#ongoing_project').dataTable({
    sDom: "<'row'<'col-sm-12'f>r>t<'row'<'col col-sm-12'p>>",
    sPaginationType: "full_numbers",
    iDisplayLength:25,
    aaSorting: [[ 1, "asc" ]],
    aoColumnDefs: [{bSortable: false, aTargets: [ -1 ] }],
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
    sAjaxSource: $('#ongoing_project').data('source')
  });

  //Code for ajax supported tabs.
  $('#projectTabs a').on('shown.bs.tab', function (e) {
    console.log("inside");
    var target = $(e.target).attr('href');// activated tab
    if(target == '#completedProj_tab'){
      showCompletedProjTable();
    }else if(target == '#ongoingProj_tab'){
      //showCurrentProjTable();
    }
  });

  function showCompletedProjTable(){
    if(completedProj === null){
      //if the table is null then its first load. Initialize table and show
      completedProj = $('#completed_project').dataTable({
        sDom: "<'row'<'col-sm-12'f>r>t<'row'<'col col-sm-12'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:25,
        aaSorting: [[ 1, "asc" ]],
        aoColumnDefs: [{bSortable: false, aTargets: [ -1 ] }],
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
        sAjaxSource: $('#completed_project').data('source')
      });
    }
  }

  // script for toggling new project form
  $('a#add_project').click( function(e){
    $('.project_add').toggle('slow');
    $('#close_ticket').hide();
  });

  $('a#bck_project').click( function(e){
    $('.project_add').hide();
    $('#close_ticket').hide();
  });

  $('#proj-Task').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#proj-Task').data('source')
  });

  var projInvoiceTable = null;
  var projReceiptTable = null;
  var projExpenseTable = null;
  var projPurchaseTable = null;
  var projPurchaseOrderTable = null;
  var projSalesOrderTable = null;
  var projJournalTable = null;

  //Code for ajax supported project detail tabs.
  $('#projViewTabs a').on('shown.bs.tab', function (e) {
    var target = $(e.target).attr('href');// activated tab
    if(target == '#proj-invoices-tab'){
      showProjInvoicesTable();
    }else if(target == '#proj-receive-money-tab'){
      showProjReceiptsTable();
    }else if(target == '#proj-expenses-tab'){
      showProjExpensesTable();
    }else if(target == '#proj-purchase-tab'){
      showProjPurchasesTable();
    }else if (target == "#proj-purchase-order-tab"){
      showProjPurchaseOrderTable();
    }else if (target == "#proj-sales-order-tab"){
      showProjSalesOrderTable();
    }else if (target == "#proj-journals-tab"){
      showProjJournalTable();
    };
  });

  function showProjInvoicesTable(){
    if(projInvoiceTable === null){
      //if the table is null then its first load. Initialize table and show
      projInvoiceTable = $('#proj-invoices').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:25,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#proj-invoices').data('source')
      });
    }
  }

  function showProjReceiptsTable(){
    if(projReceiptTable === null){
      //if the table is null then its first load. Initialize table and show
      projReceiptTable = $('#proj-receipt-vouchers').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#proj-receipt-vouchers').data('source')
      });
    }
  }

  function showProjExpensesTable(){
    if(projExpenseTable === null){
      //if the table is null then its first load. Initialize table and show
      projExpenseTable = $('#proj-expenses').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#proj-expenses').data('source')
      });
    }
  }

  function showProjPurchasesTable(){
    if(projPurchaseTable === null){
      //if the table is null then its first load. Initialize table and show
      projPurchaseTable = $('#proj-purchases').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#proj-purchases').data('source')
      });
    }
  }

  function showProjPurchaseOrderTable(){
    if(projPurchaseOrderTable === null){
      //if the table is null then its first load. Initialize table and show
      projPurchaseOrderTable = $('#proj-purchase-orders').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#proj-purchase-orders').data('source')
      });
    }
  }

  function showProjSalesOrderTable(){
    if(projSalesOrderTable === null){
      //if the table is null then its first load. Initialize table and show
      projSalesOrderTable = $('#proj-sales-orders').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#proj-sales-orders').data('source')
      });
    }
  }

  function showProjJournalTable(){
    if(projJournalTable === null){
      //if the table is null then its first load. Initialize table and show
      projJournalTable = $('#proj-journals').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#proj-journals').data('source')
      });
    }
  }

});
