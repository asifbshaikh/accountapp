$(document).ready(function(){
  var productimportTable = $('#product_imports').dataTable({
      sDom: "<'row'<'col-sm-6'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-3'p>>",
      sPaginationType: "full_numbers",
      bFilter: false,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#product_imports').data('source')       
      })

   productimportTable.fnFilterOnReturn();
});