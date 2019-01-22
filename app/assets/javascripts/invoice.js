$(document).ready(function(){

  //gst invoice form
//  $("#invoice_account_id").select2();

  //ajax to fetch customer details
  $("#invoice_account_id").change(function(){
    var account_name = $("#invoice_account_id option:selected").text();
    if (account_name){
    $.ajax({
      type:'GET',
      data: {account_name: account_name},
      url: "/invoices/customer_details"
    });
  }
  });


    var invoiceTable = $('#invoices').dataTable({
      sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:25,
      aaSorting: [[0,'desc']],
      bFilter: true,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#invoices').data('source')
      }).columnFilter({aoColumns:[
       { sSelector: "#invoiceno" },
       { sSelector: "#customer", type:"select" },
       { sSelector: "#createDate", type:"date-range"  },
       { sSelector: "#dueDate", type:"date-range"  },
       { sSelector: "#amount", type: "number-range" },
       { sSelector: "#status", type: "select" },
       { sSelector: "#project", type: "select" }
       ]}
     );

   invoiceTable.fnFilterOnReturn();


   $("#invoice-filter input").addClass("input-sm form-control");
   $("#invoice-filter select").addClass("input-sm form-control");
   $("#invoice-filter input").css({'width':'150px', 'display':'inline'});
   $("#invoice-filter select").css({'width':'150px', 'display':'inline'});

   var customers = $("td#customer").attr('data-customer')

   if(customers)  {
    $.each($.parseJSON(customers), function(index, object){

      $("#customer select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
    })
   }

  $("#status select").append("<option value=0>Unpaid</option><option value=1>Draft</option><option value=2>Paid</option><option value=3>Settled</option><option value=4>Returned</option>");

  $("#invoices_range_from_2").datepicker({format: 'dd-mm-yyyy'});
  $("#invoices_range_to_2").datepicker({format: 'dd-mm-yyyy'});

  $("#invoices_range_from_3").datepicker({format: 'dd-mm-yyyy'});
  $("#invoices_range_to_3").datepicker({format: 'dd-mm-yyyy'});

  $("button").click(function(){
     $("#invoice_attachment").fadeToggle();
   });

  // exchange rate on customer select
  var currency=null;
  currency=$("select#invoice_account_id option:selected").attr('data-currency');
  if(currency){
    $("#invoice-currency").html("Currency: "+currency+"");
    $('.invoice_exc_rate').show();
  }

  $("#sales-warehouse-details select[name$='warehouse_id]']").live('change', function(){
    var warehouseId=$(this).val();
    var index = $(this).attr('data-index');
    var swdIndex = $(this).attr('data-swd_index')
    var batchEn = $(this).attr('data-batch_en')
    var quantity = $("#invoice_invoice_line_items_attributes_"+index+"_sales_warehouse_details_attributes_"+swdIndex+"_warehouse_id option:selected").attr('data-quantity');
    var productId = $("#invoice_invoice_line_items_attributes_"+index+"_sales_warehouse_details_attributes_"+swdIndex+"_warehouse_id option:selected").attr('data-product_id');
    $("#row-"+index+"-"+swdIndex+" #swqty").html("Available: "+quantity)
    if(batchEn=='true'){
      $("#row-"+index+"-"+swdIndex+" #batch-td").html('<div class="loader text-center" style="display:inline;"><img src="/assets/ajax-loader.gif"></div>');
      $.ajax({
        data: {index: index, swd_index: swdIndex, product_id: productId, warehouse_id: warehouseId },
        url: "/invoices/batch_number_details"
      });
    }
  })
  $("#sales-warehouse-details select[name$='product_batch_id]']").live('change', function(){
    var index = $(this).attr('data-index');
    var swdIndex = $(this).attr('data-swd_index')
    // var batchEn = $(this).attr('data-batch_en')
    var quantity = $("#invoice_invoice_line_items_attributes_"+index+"_sales_warehouse_details_attributes_"+swdIndex+"_product_batch_id option:selected").attr('data-quantity');
    $("#row-"+index+"-"+swdIndex+" #batchqty").html("Available: "+quantity)
  })

  $('#invoice_account_id').change(function(){
    currency=$("select#invoice_account_id option:selected").attr('data-currency');
    var value=$("select#invoice_account_id").val();
    console.log("currency is: "+ currency);
    if(value=="create_new"){
      $("div#modal1").modal('show');
    }
    if(currency){
      $("#invoice-currency").html("Currency: "+currency+"");
      $('.invoice_exc_rate').show();
    }else{
      $("#invoice-currency").html("");
      $('.invoice_exc_rate').hide();
      $('.invoice_exc_rate input:text').val("0.0");
    }
  });


 // recurring invoice radio button toggle
 $(".recursive_1").live('click', function(){
    $("#invoice_recursion_attributes_status").val("true");
    $("div.recursiveForm").show();
  });

 $(".recursive_0").live('click', function(){
    $("#invoice_recursion_attributes_status").val("false");
    $("div.recursiveForm").hide();
  });

  if($("#recursive_0").is(":checked")){
    $("div.recursiveForm").hide();
  }else{
    $("div.recursiveForm").show();
  }

  $(".btn-invoice-qty").live('click', function(){
    var index= $(this).attr('data-index');
    calculateInvoiceWarehouseQuantity(index);
  });

  $(".btn-invoice-can").live('click', function(){
    var index= $(this).attr('data-index');
    $("div#modal-qty-"+index).modal('hide');
    $("#modal-qty-"+index+" .quantity").val('');
    $("#modal-qty-"+index+" table input:checkbox").removeAttr('checked');
    $("#row"+index+" #quantity").val('');
    cal();
  });

// Invoice history block toggle
  $("#inv_history_button").click(function(){
    $("#invoice_history").slideToggle("slow");
  });

// Invoice delivery challan detials toggle
  $("#inv_dc_button").click(function(){
    $("#invoice_dc_details").slideToggle("slow");
  });


  var draftInvoiceTable = null;
  var returnInvoiceTable = null;

  $('#invoiceTabs a').on('shown.bs.tab', function (e) {
    var target = $(e.target).attr('href');
    console.log("target="+target);
    if(target == '#draft-invoices-tab'){
      showDraftInvoiceTable();
    }else if(target=='#return-invoices-tab'){
      showReturnInvoiceTable();
    }else{
      // invoiceTable.fnDraw();
    }
  });

  function showDraftInvoiceTable(){
    if(draftInvoiceTable){
      // draftInvoiceTable.fnDraw();
    }else{
      draftInvoiceTable = $('#draft-invoices').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:25,
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
        sAjaxSource: $('#draft-invoices').data('source')
      });
    }
  }

  function showReturnInvoiceTable(){
    if(returnInvoiceTable){
      // returnInvoiceTable.fnDraw();
    }else{
      returnInvoiceTable = $('#return-invoices').dataTable({
        sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
        sPaginationType: "full_numbers",
        iDisplayLength:25,
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
        sAjaxSource: $('#return-invoices').data('source')
      });
    }
  }

  var shippingAddress;
  var shippingCity;
  var shippingState;
  var shippingCountry;
  var shippingPostalCode;
  if($("input:checkbox[name=i_same_address]").is(":checked")){
    var address = $("#invoice_billing_address_attributes_address_line1").val();
    $("#invoice_shipping_address_attributes_address_line1").val(address);
    var city = $("#invoice_billing_address_attributes_city").val();
    $("#invoice_shipping_address_attributes_city").val(city);
    var state = $("#invoice_billing_address_attributes_state").val();
    $("#invoice_shipping_address_attributes_state").val(state);
    var country = $("#invoice_billing_address_attributes_country").val();
    $("#invoice_shipping_address_attributes_country").val(country);
    var postal_code = $("#invoice_billing_address_attributes_postal_code").val();
    $("#invoice_shipping_address_attributes_postal_code").val(postal_code);
  }

  $("input:checkbox[name=i_same_address]").live("click", function(){
    if($("input:checkbox[name=i_same_address]").is(":checked")){
      shippingAddress = $("#invoice_shipping_address_attributes_address_line1").val();
      shippingCity = $("#invoice_shipping_address_attributes_city").val();
      shippingState = $("#invoice_shipping_address_attributes_state").val();
      shippingCountry = $("#invoice_shipping_address_attributes_country").val();
      shippingPostalCode = $("#invoice_shipping_address_attributes_postal_code").val();
      var address = $("#invoice_billing_address_attributes_address_line1").val();
      $("#invoice_shipping_address_attributes_address_line1").val(address);
      var city = $("#invoice_billing_address_attributes_city").val();
      $("#invoice_shipping_address_attributes_city").val(city);
      var state = $("#invoice_billing_address_attributes_state").val();
      $("#invoice_shipping_address_attributes_state").val(state);
      var country = $("#invoice_billing_address_attributes_country").val();
      $("#invoice_shipping_address_attributes_country").val(country);
      var postal_code = $("#invoice_billing_address_attributes_postal_code").val();
      $("#invoice_shipping_address_attributes_postal_code").val(postal_code);
    }else{
      $("#invoice_shipping_address_attributes_address_line1").val(shippingAddress);
      $("#invoice_shipping_address_attributes_city").val(shippingCity);
      $("#invoice_shipping_address_attributes_state").val(shippingState);
      $("#invoice_shipping_address_attributes_country").val(shippingCountry);
      $("#invoice_shipping_address_attributes_postal_code").val(shippingPostalCode);
    }
  });
});


function calculateInvoiceWarehouseQuantity(index){
  var quantity=0;
  var i=1;
  var shouldExit=true
  $('.errorPlace').html('');
  $('.quantity').css("border-color",'');
  $("table#invoice-warehouse-details"+index+" tbody tr").each(function(){
    if($("table#invoice-warehouse-details"+index+" tr:eq("+i+") td:eq(0) input:checkbox").is(":checked")){
      var qty = parseFloat($("table#invoice-warehouse-details"+index+" tr:eq("+i+") td:eq(3) input:text").val());
      var avail_qty = parseFloat($("table#invoice-warehouse-details"+index+" tr:eq("+i+") td:eq(2)").html());
      if(!isNaN(qty) && qty <= avail_qty){
        quantity+=qty;
      }else if(isNaN(qty)){
        shouldExit=false
        $("table#invoice-warehouse-details"+index+" tr:eq("+i+") td:eq(3) input:text").css("border-color",'#f55');
        $('.errorPlace').html('<div class="alert alert-danger"><h6><i class="icon-danger-sign icon-large"></i><strong>Please enter quantity.</strong></h6></div>');
      }else{
        shouldExit=false
        $("table#invoice-warehouse-details"+index+" tr:eq("+i+") td:eq(3) input:text").css("border-color",'#f55');
        $('.errorPlace').html('<div class="alert alert-danger"><h6><i class="icon-danger-sign icon-large"></i><strong>Not enough stock.</strong></h6></div>');
      }
    }
    i++;
  });
  if(shouldExit){
    $("#row"+index+" #quantity").val(quantity);
    $("div#modal-qty-"+index).modal('hide');
    cal();
  }
}
