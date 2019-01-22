$(document).ready(function(){

    var jrnlTable =  $('#journals').dataTable({
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
          {  "sClass": "hidden-xs" },
          null
        ],
      sAjaxSource: $('#journals').data('source')
    }).columnFilter({aoColumns:[
        { sSelector: "#journalvoucherno" },
        { sSelector: "#journalDate", type:"date-range"  },
        { sSelector: "#journaltoacc", type:"select" },
        { sSelector: "#journalamount", type:"number-range" }
        ]}
      );

    jrnlTable.fnFilterOnReturn();
  
  $("#journals_range_from_1").datepicker({format: 'dd-mm-yyyy'});
  $("#journals_range_to_1").datepicker({format: 'dd-mm-yyyy'});    

  $("#journal-filter input").addClass("input-sm form-control");
  $("#journal-filter select").addClass("input-sm form-control");
  $("#journal-filter input").css({'width':'150px', 'display':'inline'});
  $("#journal-filter select").css({'width':'150px', 'display':'inline'});

  // to acc search for filter
    var to_accounts = $("td#journaltoacc").attr('data-journaltoaccounts')
	if(to_accounts)	{
		$.each($.parseJSON(to_accounts), function(index, object){
			$("#journaltoacc select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

 // function to clear debit and credit fields on journal screen
  $("table#journal_line_items input").live('focusout', function(){
    var index=parseInt($(this).attr('data-index'));
    index+=1;
    console.log(index);
    var amount=$(this).val();
    var type=$(this).attr('data-ttype');
    if(amount&&amount>0){
      if(type=="dr"){
        $("table#journal_line_items tr:eq("+index+") input#credit_amount").val("0.0");
      }else if(type=='cr'){
        $("table#journal_line_items tr:eq("+index+") input#amount").val("0.0");
      }
    }
  });
  // code for opening modal on add new 
  $('#journal_account_id').change(function(){
    var value=$("select#journal_account_id").val();
    if(value=="create_new"){
      $("#modal-journal-to-account").modal('show');
    }
  });
});