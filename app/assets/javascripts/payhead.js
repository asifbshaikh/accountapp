$(document).ready(function(){

   $('#payheads').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });
   

   $(document).ready(function(){
     $("#payhead_payhead_type").change(function() {
       var payhead_type = $("#payhead_payhead_type").val();
       $.ajax({
         type: 'GET',
         url : "/payheads/payroll_account?payhead_type="+payhead_type,
       });

     });
   });

  });