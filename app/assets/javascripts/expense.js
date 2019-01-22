$(document).ready(function(){
	var expenseTable = $('#expenses').dataTable({
		sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
		sPaginationType: "full_numbers",
    iDisplayLength:25,
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
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          null
        ],
		sAjaxSource: $('#expenses').data('source')
	   }).columnFilter({aoColumns:[
        { sSelector: "#expensenumber" },
        { sSelector: "#expaccount", type:"select"},
        { sSelector: "#expdate", type:"date-range" },
        { sSelector: "#project", type:"select"},
        { sSelector: "#exptype", type:"select"},
        { sSelector: "#expamount", type:"number-range"}
      ]}
    );
		expenseTable.fnFilterOnReturn();

	$("#expense-filter input").addClass("input-sm form-control");
	$("#expense-filter select").addClass("input-sm form-control");
	$("#expense-filter input").css({'width':'150px', 'display':'inline'});
	$("#expense-filter select").css({'width':'150px', 'display':'inline'});

	var accounts = $("td#expaccount").attr('data-expacc')
	if(accounts)	{
		$.each($.parseJSON(accounts), function(index, object){
			$("#expaccount select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  var creaters = $("td#exptype").attr('data-exptype')
  if(creaters) {
    $.each($.parseJSON(creaters), function(index, object){
      $("#exptype select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
  }

  // modal on add new option
  $('#expense_account_id').live("change", function(){
    currencySetting();
    var value=$("select#expense_account_id").val();
    var voucherType=$("input[type='radio'][name='expense[credit_expense]']:checked").val();
    console.log("voucher type :"+voucherType);
    if(value=="create_new"){
      if(voucherType=='0'){
        $("div[id^='modal-add-new']").modal('show');
      }else{
        $("div[id^='modal-vendor']").modal('show');
      }
    }
  });
  currencySetting();
  // currency=$("select#expense_account_id option:selected").attr('data-currency');
  // if(currency){
  //   $("#expense-currency").html("Currency: "+currency+"");
  //   $('.expense_exc_rate').show();
  // }

  $("#expenses_range_from_2").datepicker({format: 'dd-mm-yyyy'});
  $("#expenses_range_to_2").datepicker({format: 'dd-mm-yyyy'});
  function currencySetting(){
    var currency=$("select#expense_account_id option:selected").attr('data-currency');
    console.log("currency:"+currency);
    if(currency){
      $("#expense-currency").html("Currency: "+currency+"");
      $('.expense_exc_rate').show();
    }else{
      $("#expense-currency").html("");
      $('.expense_exc_rate').hide();
      $('.expense_exc_rate input:text').val("0.0");
    }
  }
});
