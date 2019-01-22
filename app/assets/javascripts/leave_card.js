$(document).ready(function(){
   $('#leave_cards').dataTable({
      sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
      
      });
    

  });