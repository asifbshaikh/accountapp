$(document).ready(function(){

var incomevoucherTable = $('#income_vouchers').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#income_vouchers').data('source') 
   }).columnFilter({aoColumns:[
       { sSelector: "#incvoucherno" },
       { sSelector: "#incDate", type:"date-range"  },
       { sSelector: "#incacc", type:"select" },
       { sSelector: "#incamount", type: "number-range" }
       ]}
     );

   incomevoucherTable.fnFilterOnReturn();


   $("#incomevoucher-filter input").addClass("input-sm form-control");
   $("#incomevoucher-filter select").addClass("input-sm form-control");
   $("#incomevoucher-filter input").css({'width':'150px', 'display':'inline'});
   $("#incomevoucher-filter select").css({'width':'150px', 'display':'inline'});

   var accounts = $("td#incacc").attr('data-incaccount')
   if(accounts)  {
    $.each($.parseJSON(accounts), function(index, object){
      $("#incacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
   }
  
  $("#income_vouchers_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#income_vouchers_range_to_1").datepicker({format: 'dd-mm-yyyy'});    

    // rendering payment mode form
	 $(".inc_transaction_type").click(function(){
    var ttype = $(this).attr("data-ttype")
    $.ajax({
      type: 'GET',
      url: "/income_vouchers/payment_mode?mode="+ttype
    });
  }); 

  $("#income_voucher_from_account_id").select2();
  $("#income_voucher_to_account_id").select2();

  // modal on add new option
  $('#income_voucher_from_account_id').change(function(){
    var value=$("select#income_voucher_from_account_id").val();
    if(value=="create_new"){
      $("#modal-other-income-from-account").modal('show');
    }
  });

  $('#income_voucher_to_account_id').change(function(){
    var value=$("select#income_voucher_to_account_id").val();
    if(value=="create_new"){
      $("#modal-other-income-to-account").modal('show');
    }
  });
  
});