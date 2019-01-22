$(document).ready(function(){

    var custTable =  $('#customers').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:50,
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      aoColumns:
        [
          null,
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          null
        ],
      sAjaxSource: $('#customers').data('source')
      }).columnFilter({aoColumns:[
        { sSelector: "#cust_name" },
         { sSelector: "#cust_email" },
        { sSelector: "#cust_primary_phone_number"}
        ]}
      );

    custTable.fnFilterOnReturn();

  $("#customer-filter input").addClass("input-sm form-control");
  $("#customer-filter select").addClass("input-sm form-control");
  $("#customer-filter input").css({'width':'150px', 'display':'inline'});
  $("#customer-filter select").css({'width':'150px', 'display':'inline'});

  // created by search for filter
  // var creaters = $("td#cust_created_by").attr('data-createdby')
  // if(creaters) {
  //   $.each($.parseJSON(creaters), function(index, object){
  //     $("#cust_created_by select").append("<option value="+object["id"]+">"+object["first_name"]+"</option>");
  //   })
  // }

  });
