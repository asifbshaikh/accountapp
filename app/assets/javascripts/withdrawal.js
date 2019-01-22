$(document).ready(function(){

    var withTable =  $('#withdrawals').dataTable({
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
      sAjaxSource: $('#withdrawals').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#withdrawvoucherno" },
       { sSelector: "#transactionDate", type:"date-range"},
       { sSelector: "#withdrawfromacc", type:"select" },
       { sSelector: "#withdrawtoacc", type:"select" },
       { sSelector: "#withdrawamount", type: "number-range" }
       
        ]}
      );

    withTable.fnFilterOnReturn();
    
  $("#withdrawals_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#withdrawals_range_to_1").datepicker({format: 'dd-mm-yyyy'});    


  $("#withdrawal-filter input").addClass("input-sm form-control");
	$("#withdrawal-filter select").addClass("input-sm form-control");
	$("#withdrawal-filter input").css({'width':'150px', 'display':'inline'});
	$("#withdrawal-filter select").css({'width':'150px', 'display':'inline'});

	// from acc search for filter
	var from_accounts = $("td#withdrawfromacc").attr('data-fromaccounts')
	if(from_accounts)	{
		$.each($.parseJSON(from_accounts), function(index, object){
			$("#withdrawfromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}
  // to acc search for filter
    var to_accounts = $("td#withdrawtoacc").attr('data-toaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#withdrawtoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  // modal on add new option
  $('#withdrawal_from_account_id').change(function(){
    var value=$("select#withdrawal_from_account_id").val();
    if(value=="create_new"){
      $("#modal-withdrawal-from-account").modal('show');
    }
  });

  $('#withdrawal_to_account_id').change(function(){
    var value=$("select#withdrawal_to_account_id").val();
    if(value=="create_new"){
      $("#modal-withdrawal-to-account").modal('show');
    }
  });

  });
