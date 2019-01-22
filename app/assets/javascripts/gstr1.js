$(document).ready(function(){

   var gstr1Table = $('#gstr1').dataTable({
      sDom: "<'row'<'col-sm-2'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
      sPaginationType: "full_numbers",
      iDisplayLength:50,
      bFilter: false,
      bProcessing: true,
      bServerSide: true,
      sAjaxSource: $('#gstr1').data('source')
      })
   gstr1Table.fnFilterOnReturn();


  });


  function changeClass(){
     $(".on-go-form").html('<div id="modal1" class="modal fade in" aria-hidden="false" style="display: block;"> <div class="cssload-loading"><i></i><i></i><i></i></div></div><div class="modal-backdrop fade in"></div>');
    var NAME = document.getElementById("btn-group");
    var currentClass = NAME.className;
    if (currentClass == "btn-group open") { // Check the current class name
        NAME.className = "btn-group";   // Set other class name
    } else {
        NAME.className = "btn-group open";  // Otherwise, use `second_name`
    }
}  

