$("#unpinv").remove();
<% unless @customer.blank? %>
	$("#custinv").after('<%= escape_javascript render :partial => "customer_invoices" %>');
<% end %>
cal();