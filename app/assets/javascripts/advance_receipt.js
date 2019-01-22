$(document).ready(function(){

  var advanceReceiptVoucherTable = $('#advance_receipt_vouchers').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
    iDisplayLength:50,
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#advance_receipt_vouchers').data('source') 
   }).columnFilter({aoColumns:[
       { sSelector: ".advrecvoucherno" },
       { sSelector: ".advrecDate", type:"date-range"  },
       { sSelector: ".advrecacc", type:"select" },
       { sSelector: ".advrecproject", type: "select" },
       { sSelector: ".advrecamount", type: "number-range" }
       ]}
     );

   advanceReceiptVoucherTable.fnFilterOnReturn();

   $(".recmoney-filter input").addClass("input-sm form-control");
   $(".recmoney-filter select").addClass("input-sm form-control");
   $(".recmoney-filter input").css({'width':'150px', 'display':'inline'});
   $(".recmoney-filter select").css({'width':'150px', 'display':'inline'});

   var accounts = $("td.recacc").attr('data-recaccount')
   if(accounts)  {
    $.each($.parseJSON(accounts), function(index, object){
      $(".advrecacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
   }
  var projects = $("td.advrecproject").attr('data-recproject')
   if(projects)  {
    $.each($.parseJSON(projects), function(index, object){
      $(".advrecproject select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
   }


  $("#recpaymode select").append("<option value='CashPayment'>Cash</option><option value='ChequePayment'>Cheque</option><option value='CardPayment'>Card</option><option value='InternetBankingPayment'>Internet Banking</option>");
   
  $("#advance_receipt_vouchers_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#advance_receipt_vouchers_range_to_1").datepicker({format: 'dd-mm-yyyy'});    
  
  // rendering payment mode form
  $(".rec_transaction_type").click(function(){
    var ttype = $(this).attr("data-ttype")
    $.ajax({
      type: 'GET',
      url: "/receipt_vouchers/payment_mode?mode="+ttype
    });
  }); 

  // script for toggling tds fields in receive money and payment voucher
  $(".rec_tds_yes").live('click', function(){
    $('.tds-rec').show();
  });
  $(".rec_tds_no").live('click', function(){
    $('.tds-rec').hide();
  });

  if($("#rec_tds_yes").is(":checked")){
    $('.tds-rec').show();
  }
  if($("#rec_tds_no").is(":checked")){
    $('.tds-rec').hide();
  }

// script for search purchase
  $("input:radio[name=invoice]").live('click', function(){
    var amount = $(this).attr('data-amount');
    var vendor = $(this).attr('data-customer');
    $('#invoice_id_auto_complete').val($(this).val());
    $('#invoice_id_auto_complete').focus();
    $('#invoice_id_auto_complete').focusout();
    $("#from_account_auto_complete").val(vendor);
    $("#receipt_voucher_amount").val(amount);
  });

  $(".invoice-btncan").live('click', function(){
    $('#invoice_id_auto_complete').val('')
    $("#from_account_auto_complete").val('');
    $("#receipt_voucher_amount").val('');
    $("div[id^='modal']").modal('hide');
  })

  // script to populate currnecy of a customer
  var custcur = new Object();
  cur = $('#receipt_voucher_from_account_id option:selected').attr('data-currency');
    if(cur){
      $('.tdsrt').hide();
    }
    $('#receipt_voucher_from_account_id').live('change', function(){
      cur = $('#receipt_voucher_from_account_id option:selected').attr('data-currency');
      if (cur){
        $('span#from_acc_cur').html("<span style='color:grey;'>Currency : </span>"+cur);
        $('.receipt_exc_rate').show();
        $('.tdsrt').hide();
      }else{
        $('.receipt_exc_rate').hide();
        $('.tdsrt').show();
        $('span#from_acc_cur').html("<span style='color:grey;'></span>");
      }

    });
});