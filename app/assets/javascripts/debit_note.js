$(document).ready(function(){

    var debitnoteTable =  $('#debit_notes').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#debit_notes').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#debitnotevoucherno" },
       { sSelector: "#debitnoteDate", type:"date-range"},
       { sSelector: "#debitnotefromacc", type:"select" },
       { sSelector: "#debitnotetoacc", type:"select" },
       { sSelector: "#debitnoteamount", type: "number-range" }
       
        ]}
      );

    debitnoteTable.fnFilterOnReturn();
  $("#debit_notes_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#debit_notes_range_to_1").datepicker({format: 'dd-mm-yyyy'});    


  $("#debitnote-filter input").addClass("input-sm form-control");
	$("#debitnote-filter select").addClass("input-sm form-control");
	$("#debitnote-filter input").css({'width':'150px', 'display':'inline'});
	$("#debitnote-filter select").css({'width':'150px', 'display':'inline'});

	// from acc search for filter
	var from_accounts = $("td#debitnotefromacc").attr('data-fromaccounts')
	if(from_accounts)	{
		$.each($.parseJSON(from_accounts), function(index, object){
			$("#debitnotefromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}
  // to acc search for filter
    var to_accounts = $("td#debitnotetoacc").attr('data-toaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#debitnotetoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  // modal on add new option
  $('#debit_note_from_account_id').change(function(){
    var value=$("select#debit_note_from_account_id").val();
    if(value=="create_new"){
      $("#modal-debit-note-from-account").modal('show');
    }
  });

  $('#debit_note_to_account_id').change(function(){
    var value=$("select#debit_note_to_account_id").val();
    if(value=="create_new"){
      $("#modal-debit-note-to-account").modal('show');
    }
  });

  });
