$(document).ready(function(){
	var paymentvoucherTable = $('#payment_vouchers').dataTable({
       sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
       sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       sAjaxSource: $('#payment_vouchers').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#paymentvoucherno" },
       { sSelector: "#paymentDate", type:"date-range"  },
       { sSelector: "#paymentacc", type:"select" },
       { sSelector: "#paymentamount", type: "number-range" }
       ]}
     );

  paymentvoucherTable.fnFilterOnReturn();

  var advancePaymentVoucherTable = $('#advance_payment_vouchers').dataTable({
       sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
       sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       aoColumns:
        [
          null,
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          null
        ],
       sAjaxSource: $('#advance_payment_vouchers').data('source')
      })

  var otherPaymentVoucherTable = $('#other_payment_vouchers').dataTable({
       sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
       sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true,
       bServerSide: true,
       aoColumns:
        [
          null,
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          null
        ],
       sAjaxSource: $('#other_payment_vouchers').data('source')
      })



    $("#payment-filter input").addClass("input-sm form-control");
    $("#payment-filter select").addClass("input-sm form-control");
    $("#payment-filter input").css({'width':'150px', 'display':'inline'});
    $("#payment-filter select").css({'width':'150px', 'display':'inline'});

    $("#advpayment-filter input").addClass("input-sm form-control");
    $("#advpayment-filter select").addClass("input-sm form-control");
    $("#advpayment-filter input").css({'width':'150px', 'display':'inline'});
    $("#advpayment-filter select").css({'width':'150px', 'display':'inline'});

   var accounts = $("td#paymentacc").attr('data-paymentaccount')
   if(accounts)  {
    $.each($.parseJSON(accounts), function(index, object){
      $("#paymentacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
   }
    var accounts = $("td#advpaymentacc").attr('data-paymentaccount')
   if(accounts)  {
    $.each($.parseJSON(accounts), function(index, object){
      $("#advpaymentacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
   }


  $("#payment_vouchers_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#payment_vouchers_range_to_1").datepicker({format: 'dd-mm-yyyy'});

  $("#advance_payment_vouchers_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#advance_payment_vouchers_range_to_1").datepicker({format: 'dd-mm-yyyy'});



//// rendering payment mode form
	$(".transaction_type").click(function(){
    var ttype = $(this).attr("data-ttype")
    $.ajax({
      type: 'GET',
      url: "/payment_vouchers/payment_mode?mode="+ttype
    });
  });

  // script for toggling tds fields in receive money and payment voucher
  $(".tds_yes").live('click', function(){
    $('.tds-pay').show();
  });
  $(".tds_no").live('click', function(){
    $('.tds-pay').hide();
  });

  if($("#tds_yes").is(":checked")){
    $('.tds-pay').show();
  }
  if($("#tds_no").is(":checked")){
    $('.tds-pay').hide();
  }

  // script for search purchase
  $("input:radio[name=purchase]").live('click', function(){
    var amount = $(this).attr('data-amount');
    var vendor = $(this).attr('data-vendor');
    $('#purchase_id_auto_complete').val($(this).val());
    $('#purchase_id_auto_complete').focus();
    $('#purchase_id_auto_complete').focusout();
    $("select#payment_voucher_to_account_id option[value='"+vendor+"']").prop("selected", true).change();
    $("#payment_voucher_amount").val(amount);
    // $('.exc_rate').show();
    // $('.hide-tds').hide();
  });

  $(".purchase-btncan").live('click', function(){
    $('#purchase_id_auto_complete').val('')
    $("select#payment_voucher_to_account_id option[value='']").prop("selected", true).change();
    $("#payment_voucher_amount").val('');
    $("div[id^='modal']").modal('hide');
  })

  // modal on add new option
  $('#payment_voucher_from_account_id').live("change",function(){
    var value=$("select#payment_voucher_from_account_id").val();
    if(value=="create_new"){
      $("#modal-payment-from-account").modal('show');
    }
  });
   $('#advpayment_voucher_from_account_id').live("change",function(){
    var value=$("select#advpayment_voucher_from_account_id").val();
    if(value=="create_new"){
      $("#modal-payment-from-account").modal('show');
    }
  });

  $('#payment_voucher_to_account_id').live("change", function(){
    var value=$("select#payment_voucher_to_account_id").val();
    if(value=="create_new"){
      $("#modal-payment-to-account").modal('show');
    }
  });


  $('#advpayment_voucher_to_account_id').live("change", function(){
    var value=$("select#advpayment_voucher_to_account_id").val();
    if(value=="create_new"){
      $("#modal-payment-to-account").modal('show');
    }
  });
  currencySetting();

  $('#payment_voucher_to_account_id').live("change", function(){
    var account_id = $(this).val();
    currencySetting();
    $.ajax({
      type: 'GET',
      data: {account_id: account_id},
      url: "/payment_vouchers/vendor_unpaid_vouchers"
    })
  });
});

function currencySetting(){
  var currency=$("select#payment_voucher_to_account_id option:selected").attr('data-currency');
  if(currency){
    $("#payment-currency").html("Currency: "+currency+"");
    $('.exc_rate').show();
  }else{
    $("#payment-currency").html("");
    $('.exc_rate').hide();
    $('.exc_rate input:text').val("1.0");
  }
}
