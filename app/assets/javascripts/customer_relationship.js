$(document).ready(function(){
   
  $('#company_customer_relationships_attributes_0_activity_status').click(function () {
    $("#time_spent_box").toggle(this.checked);
    $("#activity_notes").toggle(this.checked);
  });
   
   $('#select_template').change(function(){
    var template_no = $(this).val();
    if (template_no == 1){
      template = "welcome_email"
    }
    else if (template_no == 2){
      template = "introduction_to_profitbooks"
    }
    else if (template_no == 3){
      template = "regarding_costing_details"
    }
    else if (template_no == 4){
      template = "regarding_profitbooks_accounting_application"
    }
    else if (template_no == 5){
      template = "regarding_bank_details"
    }
    $.ajax({
      type: 'get',
      // data: {template_value: template},
      url: '/admin/companies/select_template?template_value='+template
    });
  });

   $(".complete_company_activity").live('click', function(){
    var activity_id = $(this).attr("data-activityid")
    $("input:hidden[name=activity_id]").val(activity_id);
  });

  });