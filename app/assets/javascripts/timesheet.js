   $(document).ready(function(){

   $('#timesheets').dataTable({
      sDom: "<'row'<'col-sm-6'f>r>t<'row'<'col col-sm-6'p>>",
      sPaginationType: "full_numbers",
       bFilter: true,
       bProcessing: true
    });
 });
