$(document).ready(function(){
	
//// rendering payment mode form

	var TdspaymentTable = $('#tds_vouchers').dataTable({
       sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-4'l><'col-sm-4'i><'col col-sm-4'p>>",
       sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#tds_vouchers').data('source')       
       })
    TdspaymentTable.fnFilterOnReturn();

	$(".tds_transaction_type").click(function(){
    var ttype = $(this).attr("data-ttype")
    $.ajax({
      type: 'GET',
      url: "/tds_payment_vouchers/payment_mode?mode="+ttype
    });
  }); 

  
});