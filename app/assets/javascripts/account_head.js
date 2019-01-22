$(document).ready(function(){

    var iTable =  $('#account_heads').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:50,
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#account_heads').data('source')
    }).columnFilter({aoColumns:[
        { sSelector: "#ahname" },
        { sSelector: "#ahparent"},
        { sSelector: "#ahcreatedby", type:"select" }
        ]}
      );

    iTable.fnFilterOnReturn();

  $("#accounthead-filter input").addClass("input-sm form-control");
  $("#accounthead-filter select").addClass("input-sm form-control");
  $("#accounthead-filter input").css({'width':'150px', 'display':'inline'});
  $("#accounthead-filter select").css({'width':'150px', 'display':'inline'});

  // User search for filter
    var creaters = $("td#ahcreatedby").attr('data-creater')
  if(creaters) {
    $.each($.parseJSON(creaters), function(index, object){
      $("#ahcreatedby select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
  }

  });
