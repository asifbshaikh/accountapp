$(document).ready(function(){

  var allCompaniesTable = $('#companies').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    iDisplayLength:50,
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#companies').data('source')
  }).columnFilter({aoColumns:[
     { sSelector: "#companyname"},
     // { sSelector: "#companyplan"},
     { sSelector: "#companyowner"},
     { sSelector: "#companycontact"},
     { sSelector: "#companyemail"},
     // { sSelector: "#regdate", type: "date-range" },
     ]}
   );

  allCompaniesTable.fnFilterOnReturn();

  //Variables for datatables will null assignments
  // var stockIssueTable = null;
  var monthlyExpiringCompanyTable = null;
  var expiredCompanyTable = null;
  var paidCompanyTable = null;

  //Code for ajax supported tabs.
  $('#adminCompanies a').on('shown.bs.tab', function (e) {
    var target = $(e.target).attr('href');// activated tab
    if(target == '#paid_company'){
      showPaidCompaniesTable();
    }else if(target == '#exp_month'){
      showMonthlyExpiredCompaniesTable();
    }else if(target == '#expired'){
      showExpiredCompaniesTable();
    }
  });


  function showPaidCompaniesTable(){
    if(paidCompanyTable == null){
      //if the table is null then its first load. Initialize table and show
        paidCompanyTable = $('#paid_companies').dataTable({
        sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#paid_companies').data('source')
      });
      paidCompanyTable.fnFilterOnReturn();
    }
  }


  function showMonthlyExpiredCompaniesTable(){
    if(monthlyExpiringCompanyTable == null){
      //if the table is null then its first load. Initialize table and show
        monthlyExpiringCompanyTable = $('#exps_month').dataTable({
        sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#exps_month').data('source')
      });
     monthlyExpiringCompanyTable.fnFilterOnReturn();
    }
  }

  function showExpiredCompaniesTable(){
    if(expiredCompanyTable == null){
      //if the table is null then its first load. Initialize table and show
        expiredCompanyTable = $('#expired_companies').dataTable({
        sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:50,
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#expired_companies').data('source')
      });
      expiredCompanyTable.fnFilterOnReturn();
    }
  }


  $("#company-filter input").addClass("input-sm form-control");
  $("#company-filter select").addClass("input-sm form-control");
  $("#company-filter input").css({'width':'150px', 'display':'inline'});
  $("#company-filter select").css({'width':'150px', 'display':'inline'});

 // $("#companyplan select").append("<option value=1>Free</option><option value=2>Trial</option><option value=3>SMB</option><option value=4>Enterprise</option><option value=5>Professional</option>");

  $("#companies_range_from_3").datepicker({format: 'dd-mm-yyyy'});
  $("#companies_range_to_3").datepicker({format: 'dd-mm-yyyy'});


   $('#company_activity_reports').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });

   var companyTable = $('#company_activities').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
       // "order": [[ 3, "asc" ]],
        // sScrollX: "100%",
        "aaSorting": [],
    aoColumns : [
      { "sWidth": "15%"},
      { "sWidth": "10%"},
      { "sWidth": "15%"},
      { "sWidth": "10%"},
      { "sWidth": "25%"},
      { "sWidth": "15%"},
      { "sWidth": "10%"},
    ],
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bSortable: false
    });
   companyTable.fnFilterOnReturn();


   var companyTable = $('#company_emails').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });
   companyTable.fnFilterOnReturn();

   var companyTable = $('#weekly_shedule_companies').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });
   companyTable.fnFilterOnReturn();

   var companyTable = $('#companies_delay').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });
   companyTable.fnFilterOnReturn();

   var companyTable = $('#task_delay_companies').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#task_delay_companies').data('source')
    });
   companyTable.fnFilterOnReturn();

  });
