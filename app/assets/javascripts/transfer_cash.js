$(document).ready(function(){

    var transTable =  $('#transfer_cashes').dataTable({
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
      sAjaxSource: $('#transfer_cashes').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#transfer_cashvoucherno" },
       { sSelector: "#cashtransactionDate", type:"date-range"  },
       { sSelector: "#transfer_cashfromacc", type:"select" },
       { sSelector: "#transfer_cashtoacc", type:"select" },
       { sSelector: "#transfer_cashamount", type: "number-range" }
       
        ]}
      );

    transTable.fnFilterOnReturn();
  
  $("#transfer_cashes_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#transfer_cashes_range_to_1").datepicker({format: 'dd-mm-yyyy'});    
  
  $("#transfercash-filter input").addClass("input-sm form-control");
	$("#transfercash-filter select").addClass("input-sm form-control");
	$("#transfercash-filter input").css({'width':'150px', 'display':'inline'});
	$("#transfercash-filter select").css({'width':'150px', 'display':'inline'});

	// from acc search for filter
	var from_accounts = $("td#transfer_cashfromacc").attr('data-transfromaccounts')
	if(from_accounts)	{
		$.each($.parseJSON(from_accounts), function(index, object){
			$("#transfer_cashfromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}
  // to acc search for filter
    var to_accounts = $("td#transfer_cashtoacc").attr('data-transtoaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#transfer_cashtoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  // modal on add new option
  $('#transfer_cash_transferred_from_id').change(function(){
    var value=$("select#transfer_cash_transferred_from_id").val();
    if(value=="create_new"){
      $("#modal-transferred-from-account").modal('show');
    }
  });

  $('#transfer_cash_transferred_to_id').change(function(){
    var value=$("select#transfer_cash_transferred_to_id").val();
    if(value=="create_new"){
      $("#modal-transferred-to-account").modal('show');
    }
  });
  });
