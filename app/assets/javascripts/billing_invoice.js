$(document).ready(function(){
 $('#bill_invoices').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
     bFilter: true,
     bProcessing: true
  });

 	$('.cname').change(function(){
 		var company = $(this).val();

 		$.ajax({
 			type: 'get',
 			data: {company_name: company},
 			url: '/admin/billing_invoices/get_company'
 		});
 	});
});
