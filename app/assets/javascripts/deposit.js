$(document).ready(function(){

    var depTable =  $('#deposits').dataTable({
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
      sAjaxSource: $('#deposits').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#depositvoucherno" },
       { sSelector: "#deptransactionDate", type:"date-range"  },
       { sSelector: "#depositfromacc", type:"select" },
       { sSelector: "#deposittoacc", type:"select" },
       { sSelector: "#depositamount", type: "number-range" }
       
        ]}
      );

    depTable.fnFilterOnReturn();
  
  $("#deposits_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#deposits_range_to_1").datepicker({format: 'dd-mm-yyyy'});    
  
  $("#deposit-filter input").addClass("input-sm form-control");
	$("#deposit-filter select").addClass("input-sm form-control");
	$("#deposit-filter input").css({'width':'150px', 'display':'inline'});
	$("#deposit-filter select").css({'width':'150px', 'display':'inline'});

	// from acc search for filter
	var from_accounts = $("td#depositfromacc").attr('data-depfromaccounts')
	if(from_accounts)	{
		$.each($.parseJSON(from_accounts), function(index, object){
			$("#depositfromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}
  // to acc search for filter
    var to_accounts = $("td#deposittoacc").attr('data-deptoaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#deposittoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  // modal on add new option
  $('#deposit_from_account_id').change(function(){
    var value=$("select#deposit_from_account_id").val();
    if(value=="create_new"){
      $("#modal-deposit-from-account").modal('show');
    }
  });

  $('#deposit_to_account_id').change(function(){
    var value=$("select#deposit_to_account_id").val();
    if(value=="create_new"){
      $("#modal-deposit-to-account").modal('show');
    }
  });

  });
