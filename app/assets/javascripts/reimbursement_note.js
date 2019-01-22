$(document).ready(function(){

    var reimbursementnoteTable =  $('#reimbursement_notes').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#reimbursement_notes').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#reimbursementnotevoucherno" },
       { sSelector: "#reimbursementnoteDate", type:"date-range"},
       { sSelector: "#reimbursementnotefromacc", type:"select" },
       { sSelector: "#reimbursementnotetoacc", type:"select" },
       { sSelector: "#reimbursementnoteamount", type: "number-range" }

        ]}
      );

    reimbursementnoteTable.fnFilterOnReturn();
  $("#reimbursement_notes_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#reimbursement_notes_range_to_1").datepicker({format: 'dd-mm-yyyy'});


  $("#reimbursementnote-filter input").addClass("input-sm form-control");
	$("#reimbursementnote-filter select").addClass("input-sm form-control");
	$("#reimbursementnote-filter input").css({'width':'150px', 'display':'inline'});
	$("#reimbursementnote-filter select").css({'width':'150px', 'display':'inline'});

  //Show form for uploading attachments
  $("button").click(function(){
     $("#reimbursement_note_attachment").fadeToggle();
   });

	// from acc search for filter
	var from_accounts = $("td#reimbursementnotefromacc").attr('data-fromaccounts')
	if(from_accounts)	{
		$.each($.parseJSON(from_accounts), function(index, object){
			$("#reimbursementnotefromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  // modal on add new option
  $('#reimbursement_note_from_account_id').change(function(){
    var value=$("select#reimbursement_note_from_account_id").val();
    if(value=="create_new"){
      $("#modal-reimbursement-note-from-account").modal('show');
    }
  });

  });
