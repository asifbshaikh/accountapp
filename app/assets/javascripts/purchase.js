$(document).ready(function(){


	$("#purchase_account_id").change(function(){
    var account_name = $("#purchase_account_id option:selected").text();
    if (account_name){
    $.ajax({
      type:'GET',
      data: {account_name: account_name},
      url: "/purchases/customer_details"
    });
  }
  });

	 var purchaseTable = $('#purchases').dataTable({
	   sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
	   sPaginationType: "full_numbers",
     iDisplayLength:25,
	   bFilter: true,
	   bProcessing: true,
	   bServerSide: true,
	   sAjaxSource: $('#purchases').data('source')
	   }).columnFilter({aoColumns:[
        { sSelector: "#purchasenumber" },
        { sSelector: "#vendor", type:"select"},
        { sSelector: "#duedate", type:"date-range" },
        { sSelector: "#purchasestatus", type:"select"},
        { sSelector: "#project", type:"select"},
        { sSelector: "#purchaseamount", type:"number-range"}
      ]}
    );
		purchaseTable.fnFilterOnReturn();

	$("#purchase-filter input").addClass("input-sm form-control");
	$("#purchase-filter select").addClass("input-sm form-control");
	$("#purchase-filter input").css({'width':'150px', 'display':'inline'});
	$("#purchase-filter select").css({'width':'150px', 'display':'inline'});

	var vendors = $("td#vendor").attr('data-vendors')
	if(vendors)	{
		$.each($.parseJSON(vendors), function(index, object){
			$("#vendor select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}
	$("#purchasestatus select").append("<option value=1>Paid</option><option value=0>Unpaid</option>");
	var projects = $("td#project").attr('data-projects')
	if(projects)	{
		$.each($.parseJSON(projects), function(index, object){
			$("#project select").append("<option value="+object["id"]+">"+object["name"]+"</option>");
		})
	}

  $("#purchases_range_from_2").datepicker({format: 'dd-mm-yyyy'});
  $("#purchases_range_to_2").datepicker({format: 'dd-mm-yyyy'});


	// quantity calculation in popup
	$(".btn-save").live('click', function(){
		var index= $(this).attr('data-index');
		calculateQuantity(index);
	});
	$(".btncan").live('click', function(){
		var index= $(this).attr('data-index');
		$("div#modal-qty-"+index).modal('hide');
		$("#modal-qty-"+index+" .quantity").val('');
		$("#modal-qty-"+index+" table input:checkbox").removeAttr('checked');
		$("#row"+index+" #quantity").val('');
		cal();
	});

	var purchaseReturnTable=null;
	var draftPurchaseTable=null;

	$('#purchaseTabs a').on('shown.bs.tab', function (e) {
	  var target = $(e.target).attr('href');
	  console.log("target="+target);
	  if(target=='#return-purchases-tab'){
	    showReturnPurchaseTable();
	  }else if(target=="#draft-purchases-tab"){
	  	showDraftPurchaseTable();
	  }else{

	  }
	});

	$("button").click(function(){
     $("#purchase_attachment").fadeToggle();
   });

	function showDraftPurchaseTable(){
		if(draftPurchaseTable){

		}else{
			draftPurchaseTable = $('#draft-purchases').dataTable({
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
				sAjaxSource: $('#draft-purchases').data('source')
			})
		}
	}
	function showReturnPurchaseTable(){
		if(purchaseReturnTable){

		}else{
			purchaseReturnTable = $('#purchase-returns').dataTable({
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
          	 null
        	 ],
			sAjaxSource: $('#purchase-returns').data('source')
			});
		}
	}

	// exchange rate on customer select
	var currency=null;
	currency=$("select#purchase_account_id option:selected").attr('data-currency');
	if(currency){
	  $("#purchase-currency").html("Currency: "+currency+"");
	  $('.purchase_exc_rate').show();
	}

	$('#purchase_account_id').change(function(){
	  currency=$("select#purchase_account_id option:selected").attr('data-currency');
	  var value=$("select#purchase_account_id").val();
	  console.log("value is: "+ value);
	  if(value=="create_new"){
	    $("div#modal-vendor").modal('show');
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
});

function calculateQuantity(index){
	var quantity=0
	var i =1;
	var shouldExit=true;
	$('.errorPlace').html('');
	$('.quantity').css("border-color",'');
	$("table#warehouse-details"+index+" tbody tr").each(function(){
		if($("table#warehouse-details"+index+" tr:eq("+i+") td:eq(0) input:checkbox").is(":checked")){
			var qty = parseFloat($("table#warehouse-details"+index+" tr:eq("+i+") td:eq(2) input:text").val());
			if(!isNaN(qty)){
				quantity+=qty;
			}else{
				shouldExit=false;
				$("table#warehouse-details"+index+" tr:eq("+i+") td:eq(2) input:text").css("border-color",'#f55');
				$('.errorPlace').html('<div class="alert alert-danger"><h6><i class="icon-danger-sign icon-large"></i><strong>Please enter quantity.</strong></h6></div>');
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
