$(document).ready(function(){
  var vendorimportTable = $('#vendor_imports').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: false,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#vendor_imports').data('source')       
      })

   vendorimportTable.fnFilterOnReturn();
});