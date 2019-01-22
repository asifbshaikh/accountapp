$(document).ready(function(){

   var workTable = $('#workstreams').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       iDisplayLength:50,
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#workstreams').data('source')
    });
   workTable.fnFilterOnReturn();

   var actTable = $('#comp_acts').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       iDisplayLength:50,
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#comp_acts').data('source')  
    });

    actTable.fnFilterOnReturn();

    var usrActTable = $('#user_comp_acts').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       iDisplayLength:50,
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
      sAjaxSource: $('#user_comp_acts').data('source')  
    });

    usrActTable.fnFilterOnReturn();
   
  });