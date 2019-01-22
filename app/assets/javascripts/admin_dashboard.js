$(document).ready(function(){

   var companyTable = $('#total_leads').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#total_leads').data('source')
    });
   companyTable.fnFilterOnReturn();

   var myActivityTbl = $('#my_activity').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#my_activity').data('source')
    });
   myActivityTbl.fnFilterOnReturn();


   var todayTable = null;
   var demoTable = null;
   var pastTable = null;
   var upcommingTable = null;

  //Code for ajax supported tabs.
  $('#leads_tabs a').on('shown.bs.tab', function (e) {
    var target = $(e.target).attr('href');// activated tab
    console.log("target= "+ target);
    if(target == '#todays_leads'){
      showTeamActivityTable();
    }else if(target == '#todays_demo'){
      showTodaysDemoTable();
    }else if(target == '#upcoming_leads'){
      showUpcomingActivitiesTable();
    }else if(target == '#past_leads'){
      showPastLeadsTable();
    }else{
      // myActivityTbl.fnDraw();
    }
  });

  function showTeamActivityTable(){
    if(todayTable == null){
      //if the table is null then its first load. Initialize table and show
      todayTable = $('#today_teams_tbl').dataTable({
        sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#today_teams_tbl').data('source')
      });
      todayTable.fnFilterOnReturn();
    }
  }

  function showTodaysDemoTable(){
    if(demoTable == null){
      demoTable = $('#today_demos_tbl').dataTable({
        sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#today_demos_tbl').data('source')
      });
     demoTable.fnFilterOnReturn();
    }
  }


  function showPastLeadsTable(){
    if(pastTable == null){
      pastTable = $('#past_leads_tbl').dataTable({
        sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#past_leads_tbl').data('source')
      });
     pastTable.fnFilterOnReturn();
    }
  }

  function showUpcomingActivitiesTable(){
    if(upcommingTable == null){
      upcommingTable = $('#upcoming_leads_tbl').dataTable({
        sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
        sPaginationType: "full_numbers",
        bFilter: true,
        bProcessing: true,
        bServerSide: true,
        sAjaxSource: $('#upcoming_leads_tbl').data('source')
      });
      upcommingTable.fnFilterOnReturn();
    }
  }

   var missedTable = $('#missed_company').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#missed_company').data('source')
    });
   missedTable.fnFilterOnReturn();


   var nocontactTable = $('#no_contacts').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#no_contacts').data('source')
    });
   nocontactTable.fnFilterOnReturn();
  });
