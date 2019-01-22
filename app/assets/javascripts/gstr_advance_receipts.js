  


$(document).ready(function(){
var currency=null;
var gstn=null;


    currency=$("select#purchase_account_id option:selected").attr('data-currency');
    if(currency){
      $("#purchase-currency").html("Currency: "+currency+"");
      $('.purchase_exc_rate').show();
    }

    $('#gstr_advance_receipt_from_account_id').change(function(){
      currency=$("select#gstr_advance_receipt_from_account_id option:selected").attr('data-currency');
      gstn= $("select#gstr_advance_receipt_from_account_id option:selected").attr('data-gstn');
      var value=$("select#gstr_advance_receipt_from_account_id").val();
      
      if(value=="create_new"){
        $("div#modal-customer").modal('show');
      }
      if(gstn){
          $("#purchase-gstn").html(gstn);
      }else{
          $("#purchase-gstn").html("Unavailable");
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




    var gstr_advance_receiptTable= $('#gstr_advance_receipts').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:50,
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#gstr_advance_receipts').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#gstr_advance_receiptno" },
       { sSelector: "#gstr_advance_receiptCustomer", type:"select" },
       { sSelector: "#gstr_advance_receiptDate", type:"date-range"  },
       { sSelector: "#gstr_advance_receiptamount", type: "number-range" },
       { sSelector: "#gstr_advance_receiptstatus", type: "select" }
       ]}
     );

   gstr_advance_receiptTable.fnFilterOnReturn();


   $("#gstr_advance_receipt-filter input").addClass("input-sm form-control");
   $("#gstr_advance_receipt-filter select").addClass("input-sm form-control");
   $("#gstr_advance_receipt-filter input").css({'width':'150px', 'display':'inline'});
   $("#gstr_advance_receipt-filter select").css({'width':'150px', 'display':'inline'});

   var customers = $("td#gstr_advance_receiptcustomer").attr('data-customer')
   if(customers)  {
    $.each($.parseJSON(customers), function(index, object){
      $("#gstr_advance_receiptcustomer select").append("<option value="+object.customer.id+">"+object.customer.name+"</option>");
    })
   }

  $("#gstr_advance_receiptstatus select").append("<option value='Invoiced'>Invoiced</option>");

  $("#gstr_advance_receipts_range_from_2").datepicker({format: 'dd-mm-yyyy'});
  $("#gstr_advance_receipts_range_to_2").datepicker({format: 'dd-mm-yyyy'});








});