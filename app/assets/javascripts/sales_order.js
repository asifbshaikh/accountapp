$(document).ready(function(){

   var salesorderTable = $('#sales_orders').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
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
          {  "sClass": "hidden-xs" },
          {  "sClass": "hidden-xs" },
          null
        ],
      sAjaxSource: $('#sales_orders').data('source')       
      }).columnFilter({aoColumns:[
       { sSelector: "#salesorderno" },
       { sSelector: "#salesordercustomer", type:"select" },
       { sSelector: "#salesorderDate", type:"date-range"  },
       { sSelector: "#salesorderamount", type: "number-range" },
       { sSelector: "#salesorderstatus", type: "select" }
       ]}
     );

   salesorderTable.fnFilterOnReturn();

$('#executed_order').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
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
       sAjaxSource: $('#executed_order').data('source')
    });
   $('#draft_order').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
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
       sAjaxSource: $('#draft_order').data('source')
    });
   $('#cancelled_order').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
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
       sAjaxSource: $('#cancelled_order').data('source')
    });

   $("#salesorder-filter input").addClass("input-sm form-control");
   $("#salesorder-filter select").addClass("input-sm form-control");
   $("#salesorder-filter input").css({'width':'150px', 'display':'inline'});
   $("#salesorder-filter select").css({'width':'150px', 'display':'inline'});

   var customers = $("td#salesordercustomer").attr('data-customer')
   if(customers)  {
    $.each($.parseJSON(customers), function(index, object){
      $("#salesordercustomer select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
   }
   
   var currency=null;
   currency=$("select#sales_order_customer_id option:selected").attr('data-currency');
   if(currency){
     $("#sales-order-currency").html("Currency: "+currency+"");
     $('.exc_rate').show();
   }
   // exchange rate on customer select
   $('#sales_order_customer_id').change(function(){
     currency=$("select#sales_order_customer_id option:selected").attr('data-currency');
     var value=$("select#sales_order_customer_id").val();
     console.log("currency is: "+ currency);
     if(value=="create_new"){
       $("div#modal1").modal('show');
     }
     if(currency){
       $("#sales-order-currency").html("Currency: "+currency+"");
       $('.exc_rate').show();
     }else{
       $("#sales-order-currency").html("");
       $('.exc_rate').hide();
       $('.exc_rate input:text').val("0.0");
     }
   });
  

  $("#sales_orders_range_from_2").datepicker({format: 'dd-mm-yyyy'});
  $("#sales_orders_range_to_2").datepicker({format: 'dd-mm-yyyy'}); 

  });