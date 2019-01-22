$(document).ready(function(){


    var saccTable =  $('#saccountings').dataTable({
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
      sAjaxSource: $('#saccountings').data('source')
    }).columnFilter({aoColumns:[
        { sSelector: "#saccountingvoucherno" },
        { sSelector: "#saccountingDate", type:"date-range"},
        { sSelector: "#saccountingtoacc", type:"select" },
        { sSelector: "#saccountingamount", type:"number-range" }
        ]}
      );

    saccTable.fnFilterOnReturn();
  
  $("#saccountings_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#saccountings_range_to_1").datepicker({format: 'dd-mm-yyyy'});    

  $("#saccounting-filter input").addClass("input-sm form-control");
  $("#saccounting-filter select").addClass("input-sm form-control");
  $("#saccounting-filter input").css({'width':'150px', 'display':'inline'});
  $("#saccounting-filter select").css({'width':'150px', 'display':'inline'});

  // to acc search for filter
    var to_accounts = $("td#saccountingtoacc").attr('data-saccountingtoaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#saccountingtoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}


  });