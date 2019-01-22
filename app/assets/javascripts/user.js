$(document).ready(function(){

   var userTable = $('#users_all').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#users_all').data('source') 
    });
   userTable.fnFilterOnReturn();

   var userTable = $('#users_last_months').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#users_last_months').data('source') 
    });
   userTable.fnFilterOnReturn();

   var userTable = $('#users_last3_months').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#users_last3_months').data('source')
    });
   userTable.fnFilterOnReturn();

   var userTable = $('#users_last6_months').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#users_last6_months').data('source')
    });
   userTable.fnFilterOnReturn();

   var userTable = $('#users_last9_months').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#users_last9_months').data('source')
    });
   userTable.fnFilterOnReturn();

   var userTable = $('#users_last12_months').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#users_last12_months').data('source')
    });
   userTable.fnFilterOnReturn();

   $("#users_birth_date").datepicker({format: 'dd-mm-yyyy'});
   $("#users_date_of_joining").datepicker({format: 'dd-mm-yyyy'});
    $("#users_date_of_leaving").datepicker({format: 'dd-mm-yyyy'});
   // script for super users

   $('#all_super_users').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });

   $('#channels').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-3'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });

   $('#campaigns').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-3'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });

    var userTable = $('#contacts').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#contacts').data('source')
    });
   userTable.fnFilterOnReturn();


  var employeeTable = $('#employee').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:25,
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#employee').data('source')     
      })

   employeeTable.fnFilterOnReturn();

   var inactiveTable = $('#empinactive').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#empinactive').data('source')
    });

   inactiveTable.fnFilterOnReturn();

  //User Edit information toggles
  // work detail toggle
  $('.work_detail_add').hide();
  $('a#add_work_detail').click( function(e){
    $('.work_detail_add').show();
    $('.work_detail_info').hide();
  });
  $('a#bck_work_detail').click( function(e){
    $('.work_detail_info').show();
    $('.work_detail_add').hide();
  });

   
  });
