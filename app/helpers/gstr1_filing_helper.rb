module Gstr1FilingHelper

    FILLING_STATUS_BADGES = {verified: "bg-success", uploaded: "bg-info", partially_verified: "bg-warning", failed:"bg-danger"}.with_indifferent_access

	  def format_currency(amt)
      unit = @company.country.currency_code
      number_to_currency(amt, :unit => unit+" ", :precision=> 2)
    end

    def filling_status_badge(status)
      Gstr1FilingHelper::FILLING_STATUS_BADGES[status]
    end

    def transaction_summary(info,ind,count)
	    summary_str =""
	    end_record = check_if_end(ind,count)
		summary_str += (end_record ?  "<tr style='border-top:3px solid #99d2f9'>" : "<tr>" )           
	    summary_str += (end_record ? "<td class='text-center'><strong>#{info[:key]}</strong></td>" : "<td class='text-center'>#{info[:key]}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{info[:count]}</strong></td>" : "<td class='text-center'>#{info[:count]}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:taxable_amount])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:taxable_amount])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:total_cgst])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:total_cgst])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:total_sgst])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:total_sgst])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:total_igst])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:total_igst])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:total_amount])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:total_amount])}</td>")
		summary_str += "</tr>"   

	    summary_str.html_safe
  	end

    def summary_subsection_link(summary)
      link = ""
      if ["B2B", "CDNR"].include?summary.section_type
        link = link_to "Counter Party Summary", {anchor: "#{summary.section_type}_counter_party_summary"}, "data-toggle" => "modal"
      elsif ["B2CL", "CDNUR"].include? summary.section_type
        link = link_to "State Code Summary", {anchor: "#{summary.section_type}_state_code_summary"}, "data-toggle" => "modal"
      end
      "<td>#{link}</td>".html_safe
    end


  	def hsn_summary(invoices)
  serialized_array =Array.new
  hsn_hash =Hash.new
  hsn_data_items  = Array.new
  invoices.each do |invoice|
    serialized_array.concat(invoice.get_product_wise_summary)
  end
  serial_no = 0
  serialized_array.each do |item|
    record = item.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = item.instance_variable_get(var) }
    if hsn_hash.has_key?(record["hsn_sc"])
      hsn_data = hsn_hash[record["hsn_sc"]]
      hsn_data.add_qty(record["qty"])
      hsn_data.add_value(record["val"])
      hsn_data.add_txval(record["txval"])
      hsn_data.add_iamt(record["iamt"])
      hsn_data.add_camt(record["camt"])
      hsn_data.add_samt(record["samt"])
    else 
      serial_no = serial_no + 1
      hsn_item = HsnData.new(serial_no,record["hsn_sc"], record["desc"], record["uqc"],record["qty"],record["val"],record["txval"],record["iamt"],record["camt"],record["samt"])
      hsn_hash[record["hsn_sc"]] = hsn_item  
    end
  end

  hsn_data_array = hsn_hash.values
  hsn_data_array.each do |hsn_data_obj|
     hsn_record = hsn_data_obj.instance_variables.each_with_object({}) { |var, hash| hash[var.to_s.delete("@")] = hsn_data_obj.instance_variable_get(var) }
    Rails.logger.debug "=====================HSN HASH values #{hsn_data_obj.inspect}========" 
   hsn_data_items.push({:num => hsn_record["num"],:hsn_sc => hsn_record["hsn_cd"] ,:desc => hsn_record["desc"],:uqc => hsn_record["uqc"],
        :qty => hsn_record["qty"].to_f,
        :val => hsn_record["val"].to_f.round(2),
        :txval => hsn_record["txval"].to_f.round(2),
        :iamt => hsn_record["iamt"].to_f.round(2),
        :camt => hsn_record["camt"].to_f.round(2),
        :samt => hsn_record["samt"].to_f.round(2)})
  end
	hsn_data_items
end

  def counter_party_name(ctin)
    cp_name = Customer.find_by_gstn_id_and_company_id(ctin, @company.id)
    if !cp_name.blank?
      cp_name.name
    end
  end

  def place_of_supply_state(state_code)
    State.find_by_state_code(state_code).name
  end

  def check_if_end(ind,count)
		ind == count
	end
end

