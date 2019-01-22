$(document).ready(function(){
	var purchaseTable = $('#purchase-orders').dataTable({
	   sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
	   sPaginationType: "full_numbers",
     iDisplayLength:25,
	   bFilter: true,
	   bProcessing: true,
	   bServerSide: true,
	   sAjaxSource: $('#purchase-orders').data('source')
	   })

	purchaseTable.fnFilterOnReturn();

	$("#purchase_order_account_id").change(function(){
    var account_name = $("#purchase_order_account_id option:selected").text();
    if (account_name){
    $.ajax({
      type:'GET',
      data: {account_name: account_name},
      url: "/purchase_orders/customer_details"
    });
  }
  });

  var company_currency = $("#company_cur_code");


	// exchange rate on customer select
	var currency=null;
	currency=$("select#purchase_order_account_id option:selected").attr('data-currency');
	if(currency == company_currency){
	  $("#purchase-order-currency").html("Currency: "+currency+"");
	  $('.purchase_order_exc_rate').show();
	}

	$('#purchase_order_account_id').change(function(){
	  currency=$("select#purchase_order_account_id option:selected").attr('data-currency');
	  var value=$("select#purchase_order_account_id").val();
	  console.log("value is: "+ value);
	  if(value=="create_new"){
	    $("div#modal-vendor").modal('show');
	  }
    //console.log("The company currency is "+company_currency.val());

	  if(currency == company_currency){
	    $("#purchase-order-currency").html("Currency: "+currency+"");
	    $('.purchase_order_exc_rate').show();
	  }else{
	    $("#purchase-order-currency").html("");
	    $('.purchase_order_exc_rate').hide();
	    $('.purchase_order_exc_rate input:text').val("1.0");
	  }
	});
});

