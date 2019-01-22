$(document).ready(function(){

  $('#pbreferrals').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    iDisplayLength:10,
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#pbreferrals').data('source')       
  });

});