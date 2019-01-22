module Gstr2FilingHelper
	def itc_summary_details(info,ind,count)
	    summary_str =""
	    end_record = check_if_end(ind,count)
		summary_str += (end_record ?  "<tr style='border-top:3px solid #99d2f9'>" : "<tr>" )           
	    
	    
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:eligibility])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:eligibility])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:total_igst])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:total_igst])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:total_cgst])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:total_cgst])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{format_currency(info[:total_sgst])}</strong></td>" : "<td class='text-center'>#{format_currency(info[:total_sgst])}</td>")
	    summary_str += (end_record ? "<td class='text-center'><strong>#{info[:count]}</strong></td>" : "<td class='text-center'>#{info[:count]}</td>")
	    
		summary_str += "</tr>"   

	    summary_str.html_safe
  	end
end