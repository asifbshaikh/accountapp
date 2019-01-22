 $(document).ready(function(){

    var vendTable =  $('#vendors').dataTable({
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
          null
        ],
      sAjaxSource: $('#vendors').data('source')
      }).columnFilter({aoColumns:[
        { sSelector: "#vend_name" },
        { sSelector: "#vend_email" },
        { sSelector: "#vend_primary_phone_number"}
        ]}
      );

    vendTable.fnFilterOnReturn();

  $("#vendor-filter input").addClass("input-sm form-control");
  $("#vendor-filter select").addClass("input-sm form-control");
  $("#vendor-filter input").css({'width':'150px', 'display':'inline'});
  $("#vendor-filter select").css({'width':'150px', 'display':'inline'});

  // created by search for filter
  // var creaters = $("td#cust_created_by").attr('data-createdby')
  // if(creaters) {
  //   $.each($.parseJSON(creaters), function(index, object){
  //     $("#cust_created_by select").append("<option value="+object["id"]+">"+object["first_name"]+"</option>");
  //   })
  // }

  });
