$(document).ready(function(){
	$("#reimbursement_data").html("<%= escape_javascript(render :partial => 'get_reimbursement_notes_for_account') %>");
});