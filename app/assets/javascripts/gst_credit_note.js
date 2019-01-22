$(document).ready(function(){

    var gstcreditnoteTable =  $('#gst_credit_notes').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#gst_credit_notes').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#gstcreditnotevoucherno" },
       { sSelector: "#gstcreditnoteDate", type:"date-range"},
       { sSelector: "#gstcreditnotetoacc", type:"select" },
       { sSelector: "#gstcreditnoteamount", type: "number-range" },
       { sSelector: "#status", type: "select" }
        ]}
      );

    gstcreditnoteTable.fnFilterOnReturn();
  	$("#gst_credit_notes_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  	$("#gst_credit_notes_range_to_1").datepicker({format: 'dd-mm-yyyy'});    

  	$("#gstcreditnote-filter select").append("<option value=0>Open</option><option value=1>Allocated</option><option value=2>Refund</option>");
  	$("#gstcreditnote-filter input").addClass("input-sm form-control");
	$("#gstcreditnote-filter select").addClass("input-sm form-control");
	$("#gstcreditnote-filter input").css({'width':'150px', 'display':'inline'});
	$("#gstcreditnote-filter select").css({'width':'150px', 'display':'inline'});

		// from acc search for filter
  // to acc search for filter
    var to_accounts = $("td#gstcreditnotetoacc").attr('data-toaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#gstcreditnotetoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

});