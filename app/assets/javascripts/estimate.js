$(document).ready(function(){

//ajax to fetch customer details
  $("#estimate_account_id").change(function(){
    var account_name = $("#estimate_account_id option:selected").text();
    if (account_name){
    $.ajax({
      type:'GET',
      data: {account_name: account_name},
      url: "/estimates/customer_details"
    });
  }
  });



  $("#add-tax").live("click", function(){
    var index = $(this).attr("data-index");
    $("#tax-"+index+"-1").show();
    $(this).remove();
  });
 // Estimate history block toggle
  $("#estimate_history_button").click(function(){
    $("#estimate_history").slideToggle("slow");
  });

   var estimateTable = $('#estimates').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:50,
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#estimates').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#estimateno" },
       { sSelector: "#estimatecustomer", type:"select" },
       { sSelector: "#estimateDate", type:"date-range"  },
       { sSelector: "#estimateamount", type: "number-range" },
       { sSelector: "#estimatestatus", type: "select" }
       ]}
     );

   estimateTable.fnFilterOnReturn();


   $("#estimate-filter input").addClass("input-sm form-control");
   $("#estimate-filter select").addClass("input-sm form-control");
   $("#estimate-filter input").css({'width':'150px', 'display':'inline'});
   $("#estimate-filter select").css({'width':'150px', 'display':'inline'});

   var customers = $("td#estimatecustomer").attr('data-customer')
   if(customers)  {
    $.each($.parseJSON(customers), function(index, object){
      $("#estimatecustomer select").append("<option value="+object.customer.id+">"+object.customer.name+"</option>");
    })
   }

  $("#estimatestatus select").append("<option value='Invoiced'>Invoiced</option>");

  $("#estimates_range_from_2").datepicker({format: 'dd-mm-yyyy'});
  $("#estimates_range_to_2").datepicker({format: 'dd-mm-yyyy'});

  // exchange rate on customer select
  var currency=null;
  currency=$("select#estimate_account_id option:selected").attr('data-currency');
  if(currency){
    $("#estimate-currency").html("Currency: "+currency+"");
    $('.estimate_exc_rate').show();
  }

  $('#estimate_account_id').change(function(){
    currency=$("select#estimate_account_id option:selected").attr('data-currency');
    var value=$("select#estimate_account_id").val();

    if(value=="create_new"){
      $("div#modal1").modal('show');
    }
    if(currency){
      $("#estimate-currency").html("Currency: "+currency+"");
      $('.estimate_exc_rate').show();
   }else{
      $("#estimate-currency").html("");
      $('.estimate_exc_rate').hide();
      $('.estimate_exc_rate input:text').val("0.0");
    }
  });

  });
