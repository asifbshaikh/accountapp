$(document).ready(function(){

    var gstdebitnoteTable =  $('#gst_debit_notes').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#gst_debit_notes').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#gstdebitnotevoucherno" },
       { sSelector: "#gstdebitnoteDate", type:"date-range"},
       { sSelector: "#gstdebitnotefromacc", type:"select" },
       { sSelector: "#status", type: "select" },
       { sSelector: "#gstdebitnoteamount", type: "number-range" }
        ]}
      );

    gstdebitnoteTable.fnFilterOnReturn();
    $("#gst_debit_notes_range_from_1").datepicker({format: 'dd-mm-yyyy'});
    $("#gst_debit_notes_range_to_1").datepicker({format: 'dd-mm-yyyy'});    

    $("#gstdebitnote-filter select").append("<option value=0>Open</option><option value=1>Allocated</option><option value=2>Refund</option>");
    $("#gstdebitnote-filter input").addClass("input-sm form-control");
    $("#gstdebitnote-filter select").addClass("input-sm form-control");
    $("#gstdebitnote-filter input").css({'width':'150px', 'display':'inline'});
    $("#gstdebitnote-filter select").css({'width':'150px', 'display':'inline'});

    // from acc search for filter
  // to acc search for filter
    var from_accounts = $("td#gstdebitnotefromacc").attr('data-fromaccounts')
  if(from_accounts) {
    $.each($.parseJSON(from_accounts), function(index, object){
      $("#gstdebitnotefromacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
  }

});