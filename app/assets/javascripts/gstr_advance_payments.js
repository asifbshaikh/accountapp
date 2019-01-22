$(document).ready(function(){
var currency=null;
var gstn=null;


    currency=$("select#purchase_account_id option:selected").attr('data-currency');
    if(currency){
      $("#purchase-currency").html("Currency: "+currency+"");
      $('.purchase_exc_rate').show();
    }

    $('#gstr_advance_payment_to_account_id').change(function(){
      currency=$("select#gstr_advance_payment_to_account_id option:selected").attr('data-currency');
      gstn= $("select#gstr_advance_payment_to_account_id option:selected").attr('data-gstn');
      var value=$("select#gstr_advance_payment_to_account_id").val();
      console.log("value is: "+ value);
      if(value=="create_new"){
        $("div#modal-customer").modal('show');
      }
      if(gstn){
          $("#purchase-gstin").html(gstn);
      }else{
          $("#purchase-gstin").html("Unavailable");
      }


      if(currency){
        $("#purchase-currency").html("Currency: "+currency+"");
        $('.purchase_exc_rate').show();
      }else{
        $("#purchase-currency").html("");
        $('.purchase_exc_rate').hide();
        $('.purchase_exc_rate input:text').val("0.0");
      }
    });




    var gstr_advance_paymentTable= $('#gstr_advance_payments').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:50,
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#gstr_advance_payments').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#gstr_advance_paymentno" },
       { sSelector: "#gstr_advance_paymentcustomer", type:"select" },
       { sSelector: "#gstr_advance_paymentDate", type:"date-range"  },
       { sSelector: "#gstr_advance_paymentamount", type: "number-range" },
       { sSelector: "#gstr_advance_paymentstatus", type: "select" }
       ]}
     );

   gstr_advance_paymentTable.fnFilterOnReturn();


   $("#gstr_advance_payment-filter input").addClass("input-sm form-control");
   $("#gstr_advance_payment-filter select").addClass("input-sm form-control");
   $("#gstr_advance_payment-filter input").css({'width':'150px', 'display':'inline'});
   $("#gstr_advance_payment-filter select").css({'width':'150px', 'display':'inline'});

   var customers = $("td#gstr_advance_paymentcustomer").attr('data-customer')
   if(customers)  {
    $.each($.parseJSON(customers), function(index, object){
      $("#gstr_advance_paymentcustomer select").append("<option value="+object.customer.id+">"+object.customer.name+"</option>");
    })
   }

  $("#gstr_advance_paymentstatus select").append("<option value='Purchased'>Purchased</option>");

  $("#gstr_advance_payments_range_from_2").datepicker({format: 'dd-mm-yyyy'});
  $("#gstr_advance_payments_range_to_2").datepicker({format: 'dd-mm-yyyy'});








});