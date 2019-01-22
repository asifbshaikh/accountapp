$(document).ready(function(){

   $('#messages').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#messages').data('source')
    });

   $('#sent_messages').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#sent_messages').data('source')
    });
  });