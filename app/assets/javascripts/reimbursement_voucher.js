$(document).ready(function(){

    var reimbursementvoucherTable =  $('#reimbursement_vouchers').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#reimbursement_vouchers').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#rimbvouchervoucherno" },
       { sSelector: "#rimbvouchervoucherdate", type:"date-range"},
       { sSelector: "#rimbvoucherfromacc", type:"select" }
        ]}
      );

    reimbursementvoucherTable.fnFilterOnReturn();
  $("#reimbursement_vouchers_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#reimbursement_vouchers_range_to_1").datepicker({format: 'dd-mm-yyyy'});


  $("#rimbvoucher-filter input").addClass("input-sm form-control");
	$("#rimbvoucher-filter select").addClass("input-sm form-control");
	$("#rimbvoucher-filter input").css({'width':'150px', 'display':'inline'});
	$("#rimbvoucher-filter select").css({'width':'150px', 'display':'inline'});

	// from acc search for filter
	var from_accounts = $("td#rimbvoucherfromacc").attr('data-fromaccounts')
	if(from_accounts)	{
		$.each($.parseJSON(from_accounts), function(index, object){
			$("#rimbvoucherfromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  // modal on add new option
  $('#reimbursement_voucher_from_account_id').change(function(){
    var value=$("select#reimbursement_voucher_from_account_id").val();
    if(value=="create_new"){
      $("#modal-reimbursement-note-from-account").modal('show');
    }
  });

  // Date picker for Reimbursement Voucher
  $("#reimbursement_voucher_voucher_date").datepicker({format: 'dd-mm-yyyy'});


  // populate generated Reimbursement Notes for the selected account
  $('#reimbursement_voucher_from_account_id').change(function(){
    var value=$("select#reimbursement_voucher_from_account_id").val();
    $.ajax({
    url: "/reimbursement_vouchers/get_reimbursement_notes_for_account?account_id="+value,
    type: 'GET'
    });
  });

  });
