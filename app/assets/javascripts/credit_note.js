$(document).ready(function(){

    var creditnoteTable =  $('#credit_notes').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#credit_notes').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#creditnotevoucherno" },
       { sSelector: "#creditnoteDate", type:"date-range"},
       { sSelector: "#creditnotefromacc", type:"select" },
       { sSelector: "#creditnotetoacc", type:"select" },
       { sSelector: "#creditnoteamount", type: "number-range" }
       
        ]}
      );

    creditnoteTable.fnFilterOnReturn();
  $("#credit_notes_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#credit_notes_range_to_1").datepicker({format: 'dd-mm-yyyy'});    


  $("#creditnote-filter input").addClass("input-sm form-control");
	$("#creditnote-filter select").addClass("input-sm form-control");
	$("#creditnote-filter input").css({'width':'150px', 'display':'inline'});
	$("#creditnote-filter select").css({'width':'150px', 'display':'inline'});

	// from acc search for filter
	var from_accounts = $("td#creditnotefromacc").attr('data-fromaccounts')
	if(from_accounts)	{
		$.each($.parseJSON(from_accounts), function(index, object){
			$("#creditnotefromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}
  // to acc search for filter
    var to_accounts = $("td#creditnotetoacc").attr('data-toaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#creditnotetoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  // modal on add new option
  $('#credit_note_from_account_id').change(function(){
    var value=$("select#credit_note_from_account_id").val();
    if(value=="create_new"){
      $("#modal-credit-note-from-account").modal('show');
    }
  });

  $('#credit_note_to_account_id').change(function(){
    var value=$("select#credit_note_to_account_id").val();
    if(value=="create_new"){
      $("#modal-credit-note-to-account").modal('show');
    }
  });

  });
