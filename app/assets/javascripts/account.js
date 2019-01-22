$(document).ready(function(){

    var iTable =  $('#accounts').dataTable({
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
      sAjaxSource: $('#accounts').data('source')
    }).columnFilter({aoColumns:[
        { sSelector: "#name" },
        { sSelector: "#account_head", type:"select" },
        { sSelector: "#account_type"},
        { sSelector: "#created_by", type:"select" }
        ]}
      );

    iTable.fnFilterOnReturn();

  $("#account-filter input").addClass("input-sm form-control");
  $("#account-filter select").addClass("input-sm form-control");
  $("#account-filter input").css({'width':'150px', 'display':'inline'});
  $("#account-filter select").css({'width':'150px', 'display':'inline'});

  //Account group search for filter
  var account_heads = $("td#account_head").attr('data-group')
  if(account_heads) {
    $.each($.parseJSON(account_heads), function(index, object){
      $("#account_head select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
  }
  // User search for filter
    var creaters = $("td#created_by").attr('data-creater')
  if(creaters) {
    $.each($.parseJSON(creaters), function(index, object){
      $("#created_by select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
  }

  });


function itemCost(unit_rate, discount, data) {
  tax_rate=taxRate(data);
  return (unit_rate*(1-(discount/100.0)))/(1+(tax_rate/100.0))
}

function taxRate(data){

  ind_tax_rate=0;
  parent_tax_rate=0;
  $.each($.parseJSON(data), function(index, object){
    var tax_rate = parseFloat(object["rate"]);
    var calculate_on_percent= parseFloat(object["calculate_on_percent"]);
    var calculation_method=object["calculation_method"]
    if(object["parent"]){
      parent_tax_rate=tax_rate*(calculate_on_percent/100.0);
     if(calculation_method!=4) 
     {
      ind_tax_rate=parent_tax_rate;
     }
    }else{
      if(calculation_method=="2"){
        ind_tax_rate+=tax_rate*((calculate_on_percent+parent_tax_rate)/100.0)
      }else if(calculation_method=="3"){
        ind_tax_rate+=tax_rate
      }else{
        ind_tax_rate+=(parent_tax_rate*(tax_rate/100.0))
      }
    }
  });
  return ind_tax_rate;
}
