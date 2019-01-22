$(document).ready(function(){

  var all_leadTable = $('#leads').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    iDisplayLength:25,
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#leads').data('source')       
  }).columnFilter({aoColumns:[
   { sSelector: "#leadname"},
   { sSelector: "#leadmobile"},
   { sSelector: "#leademail"},
   { sSelector: "#leadchannel", type:'select'},
   { sSelector: "#leadcampaign", type: 'select'},
   { sSelector: "#leadsmood", type: "select" },
   { sSelector: "#leadassignedto", type: "select" }
   ]}
   );

  all_leadTable.fnFilterOnReturn();

  var interested_leadTable = $('#interested').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    iDisplayLength: 25,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#interested').data('source')
  });

  interested_leadTable.fnFilterOnReturn();

  var open_leadTable = $('#unassigned').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    iDisplayLength: 25,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#unassigned').data('source')
  });

  open_leadTable.fnFilterOnReturn();

  var junk_leadTable = $('#junk_leads_table').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    iDisplayLength: 25,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#junk_leads_table').data('source')
  });

  junk_leadTable.fnFilterOnReturn();


  var won_leadTable = $('#won_leads_table').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    iDisplayLength: 25,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#won_leads_table').data('source')
  });

  won_leadTable.fnFilterOnReturn();

  var my_leadTable = $('#my_leads').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    iDisplayLength: 25,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#my_leads').data('source')
  });

  my_leadTable.fnFilterOnReturn();

  var leadTable = $('#not_interested').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    iDisplayLength: 25,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#not_interested').data('source')
  });

  leadTable.fnFilterOnReturn();

  var leadTable = $('#noresponse').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#noresponse').data('source')
  });

  leadTable.fnFilterOnReturn();

  var leadTable = $('#might_buy').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#might_buy').data('source')
  });

  leadTable.fnFilterOnReturn();


  $("#lead-filter input").addClass("input-sm form-control");
  $("#lead-filter select").addClass("input-sm form-control");
  $("#lead-filter input").css({'width':'150px', 'display':'inline'});
  $("#lead-filter select").css({'width':'150px', 'display':'inline'});

  $("#leadsmood select").append("<option value=2>Red</option><option value=1>Green</option><option value=0>Amber</option>");

  var channels = $("td#leadchannel").attr('data-channel')
  if(channels)  {
    $.each($.parseJSON(channels), function(index, object){
      $("#leadchannel select").append("<option value="+object["id"]+">"+object["channel_name"]+"</option>");
    })
  }

  var campaigns = $("td#leadcampaign").attr('data-campaign')
  if(campaigns)  {
    $.each($.parseJSON(campaigns), function(index, object){
      $("#leadcampaign select").append("<option value="+object["id"]+">"+object["campaign_name"]+"</option>");
    })
  }

  var assigned_to = $("td#leadassignedto").attr('data-assigned')
  if(assigned_to)  {
    $.each($.parseJSON(assigned_to), function(index, object){
      $("#leadassignedto select").append("<option value="+object["id"]+">"+object["super_user_name"]+"</option>");
    })
  }




  $('#act_details').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });

  $('#activity_reports').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });


  $('#lead_activities').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    "aaSorting": [],
    aoColumns : [
    { "sWidth": "15%"},
    { "sWidth": "15%"},
    { "sWidth": "15%"},
    { "sWidth": "15%"},
    { "sWidth": "25%"},
    { "sWidth": "15%"},
    ],
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });


  var demoTable = $('#demo').dataTable({
    sDom: "<'row'<'col-sm-8'f><'col-sm-4'>r>t<'row'<'col-sm-3'l><'col-sm-4'i><'col col-sm-5'p>>",
    sPaginationType: "full_numbers",
    iDisplayLength:50,
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#demo').data('source')       
  }).columnFilter({aoColumns:[
   { sSelector: "#demoname"},
   { sSelector: "#demomobile"},
   { sSelector: "#demoemail"}
   ]}
   );

  demoTable.fnFilterOnReturn();

  $(".lead_action").click(function(){
    var ttype = $(this).attr("data-ttype")
    var l_id = $(this).attr("data-lid")
    $.ajax({
      type: 'GET',
      data:{target_action:ttype, lead_id:l_id},

      url: "/admin/leads/lead_action"
    });
  }); 


  var lead_datatable = $('#exp_rep').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#exp_rep').data('source')  
  });
  lead_datatable.fnFilterOnReturn();

  lead_datatable = $('#lead_emails').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });
  lead_datatable.fnFilterOnReturn();

  $('#leads_report').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });

  $('.act_add').hide();
  $('a#add_act').click( function(e){
    $('.act_add').toggle('slow');
    $('.act_info').hide();
    $('#close_ticket').hide();
    // e.stopProgration();
  });

  $('a#bck_act').click( function(e){
    $('.act_info').toggle('slow');
    $('.act_add').hide();
    $('#close_ticket').hide();
    // e.stopProgration();
  });

  $('.channel_add').hide();
  $('a#add_channel').click( function(e){
    $('.channel_add').toggle('slow');
    $('.channel_info').hide();
    $('#close_ticket').hide();
    // e.stopProgration();
  });

  $('a#bck_channel').click( function(e){
    $('.channel_info').toggle('slow');
    $('.channel_add').hide();
    $('#close_ticket').hide();
    // e.stopProgration();
  });

  $('.campaign_add').hide();
  $('a#add_campaign').click( function(e){
    $('.campaign_add').toggle('slow');
    $('.campaign_info').hide();
    $('#close_ticket').hide();
    // e.stopProgration();
  });

  $('a#bck_campaign').click( function(e){
    $('.campaign_info').toggle('slow');
    $('.campaign_add').hide();
    $('#close_ticket').hide();
    // e.stopProgration();
  });

  $("#flip").click(function(){
    $("#cc_text_box").slideToggle("slow");
  });

  $('#lead_lead_activities_attributes_0_activity_status').click(function () {
    $("#time_spent_box").toggle(this.checked);
  });

  var leadTable = $('#weekly_shedule_leads').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });
  leadTable.fnFilterOnReturn();

  var leadTable = $('#leads_delay').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });
  leadTable.fnFilterOnReturn();

  var leadTable = $('#task_delay_leads').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true,
    bServerSide: true,
    sAjaxSource: $('#task_delay_leads').data('source')      
  });
  leadTable.fnFilterOnReturn();

  var leadTable = $('#leads_deleted').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });
  leadTable.fnFilterOnReturn();

  var leadTable = $('#activity_time').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });
  leadTable.fnFilterOnReturn();

  var leadTable = $('#channel_summary').dataTable({
    sDom: "<'row'<'col-sm-6'l><'col-sm-6'f>r>t<'row'<'col-sm-6'i><'col col-sm-6'p>>",
    sPaginationType: "full_numbers",
    bFilter: true,
    bProcessing: true
  });
  leadTable.fnFilterOnReturn();

  $(".complete_activity").click(function(){
   var activity_id = $(this).attr("data-id")
   $.ajax({

    type: 'GET',
    data: {Activity_id: activity_id},
    url: "/admin/leads/update_activity"
  });
 });

  $('#lead_lead_activities_attributes_0_activity_status').click(function () {
    $("#time_spent_box").toggle(this.checked);
    $("#activity_notes").toggle(this.checked);
  });

  $('#select_email_template').change(function(){
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
      url: '/admin/leads/select_template?template_value='+template
    });
  });


  $(".complete_lead_activity").live('click', function(){
    var activity_id = $(this).attr("data-activityid")
    $("input:hidden[name=activity_id]").val(activity_id);
  });

});
