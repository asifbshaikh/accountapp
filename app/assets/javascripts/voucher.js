$(document).ready(function(){
  
  $("a#transaction_type").click(function(){
    var ttype = $(this).attr("data-ttype")
    // var pay_mode = $(this).val()
    var source = $("#source").val();
    var req_url = "";

    if (source == 'payment'){
      req_url = "/payment_vouchers/payment_mode?mode="+ttype;
    }else if (source == 'income') {
      req_url = "/income_vouchers/payment_mode?mode="+ttype;
    }else if (source == 'receipt'){
      req_url = "/receipt_vouchers/payment_mode?mode="+ttype; 
    }

    $.ajax({
      type: 'GET',
      url: req_url,
      success: function(partial){
        $("#open_account").insertAfter(partial);
      },
    });
  }); 
});


