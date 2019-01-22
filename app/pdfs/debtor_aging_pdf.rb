class DebtorAgingPdf < Prawn::Document
	include PdfBase
	require 'open-uri'
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, invoice, company,start_date,end_date)
  	  super(HORIZONTAL_PAGE_LAYOUT)
	  @view_context=view_context
	  @invoice=invoice
	  @company=company
	  @start_date = start_date
	  @end_date = end_date
	  @pos_arr=[]
	  @header_pos=[]
	  send "generate_debtor_aging_report"
	end

	def generate_debtor_aging_report
		y_pos=cursor
		bounding_box([0, y_pos], :width=>bounds.width) do
			company_name_and_address_in_center

			 report_details
		end
		debtor_aging_details
		page_footer
	end

	def report_details
		text"<b><u>Debtor Aging Report From: #{@start_date} To #{@end_date} </u></b>", :align=>:center, :size=>10, :inline_format=>true
 	end

	def debtor_aging_details
	    data=Array.new
  		data<<table_header
		data=data.concat(report_data)
		data<<grand_total[0]
		data<<grand_total[1]
		data<<grand_total[2]
		table(data, :header=>true, :width=>bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style =>{:border_width => 0,:border_color => "70B8FF",  :size => 8}, :column_widths => {0 => 30,2=>70,3=>50}) do
			row(0).font_style=:bold
	   	    row(0).borders=[:top, :bottom]
	    	row(0).border_width=0.2
    end
	end
	def grand_total
		total_outstanding =0
		total_outstanding1 =0
		total_outstanding2 =0
		total_outstanding3 =0
		total_outstanding4 =0
		total_outstanding5 =0
		count =0 
		count1=0
		count2=0
		count3=0
		count4=0
		count5=0 
		percentage =0
		percentage1 =0
		percentage2 =0
		percentage3 =0
		@invoice.each do |invoice|
 			count += 1
			total_outstanding += invoice.outstanding
			outstanding_days = (Time.zone.now.to_date - invoice.invoice_date)
			if outstanding_days <31  
               total_outstanding1 += invoice.outstanding
				count1+=1	               
           end
           if outstanding_days >30 && outstanding_days <61  
               total_outstanding2 += invoice.outstanding
				count2+=1	               
           end
           if outstanding_days >60 && outstanding_days <91
               total_outstanding3 += invoice.outstanding
				count3+=1	               
           end
           if outstanding_days >90 && outstanding_days <181 
               total_outstanding4 += invoice.outstanding
				count4+=1	               
           end
           if outstanding_days > 180
               total_outstanding5 += invoice.outstanding
				count5+=1	               
           end
 		end
		
		percentage = (total_outstanding1/total_outstanding)*100
		percentage1 = (total_outstanding2/total_outstanding)*100
		percentage2 = (total_outstanding3/total_outstanding)*100
		percentage3 = (total_outstanding4/total_outstanding)*100
		percentage4 = (total_outstanding5/total_outstanding)*100
		 invoice_total=[]
		 invoice_total<<["","",{:content=>"Total No. of",:align=>:right, :font_style=>:bold},{:content=>"Invoices ",:align=>:left, :font_style=>:bold},{:content=>"#{count}", :font_style=>:bold, :align=>:right}, {:content=>"#{count1}", :font_style=>:bold, :align=>:right},{:content=>"#{count2}", :font_style=>:bold, :align=>:right}, {:content=>"#{count3}", :font_style=>:bold, :align=>:right},{:content=>"#{count4}", :font_style=>:bold, :align=>:right},{:content=>"#{count5}", :font_style=>:bold, :align=>:right}]
		 invoice_total << ["","",{:content=>"Total Amount",:align=>:right, :font_style=>:bold},"",{:content=>"#{number_with_precision total_outstanding, :precision=>2}",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision total_outstanding1, :precision=>2}",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision total_outstanding2, :precision=>2}",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision total_outstanding3, :precision=>2}",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision total_outstanding4, :precision=>2}",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision total_outstanding5, :precision=>2}",:font_style=>:bold, :align=>:right}]
		 invoice_total <<["","",{:content=>"Percentage",:align=>:right, :font_style=>:bold},"","",{:content=>"#{number_with_precision percentage, :precision=>2}"+"%",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision percentage1, :precision=>2}"+"%",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision percentage2, :precision=>2}"+"%",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision percentage3, :precision=>2}"+"%",:font_style=>:bold, :align=>:right},{:content=>"#{number_with_precision percentage4, :precision=>2}"+"%",:font_style=>:bold, :align=>:right}]
		 invoice_total
 	 end

	def report_data
		data=Array.new
		count=0
		@invoice.each do |invoice|
			outstanding_days = (Time.zone.now.to_date - invoice.invoice_date)
			 if invoice.outstanding > 0
			data<<["#{count+=1}","#{invoice.customer_name}","#{invoice.invoice_number}", "#{invoice.invoice_date}", {:content =>"#{number_with_precision invoice.outstanding,:precision=>2}",:align=>:right}, {:content=>"#{outstanding_days < 31 ? "#{number_with_precision invoice.outstanding, :precision=>2}" : ''}", :align=>:right}, {:content=>"#{outstanding_days > 30 && outstanding_days <61 ? "#{number_with_precision invoice.outstanding,:precision=>2 }" : ''}", :align=>:right}, {:content=>"#{outstanding_days > 60 && outstanding_days <91 ? "#{number_with_precision invoice.outstanding,:precision=>2}" : ''}", :align=>:right}, {:content=>"#{outstanding_days > 90 && outstanding_days <181 ? "#{number_with_precision invoice.outstanding,:precision=>2}" : ''}", :align=>:right}, {:content=>"#{outstanding_days > 180  ? "#{number_with_precision invoice.outstanding,:precision=>2}" : ''}", :align=>:right}]
		  end	
		end
		data
	end
	def table_header
		[{:content=>"Sr.no"}, "Customer Name", "Invoice No.","Invoice Date", {:content=>"Outstanding Amount(#{@company.currency_code})",:align=>:right}, {:content=>"1-30 days", :align=>:right}, {:content=>"31-60 days", :align=>:right}, {:content=>"61-90 days", :align=>:right}, {:content=>"91-180 days", :align=>:right}, {:content=>"More Than 180 days", :align=>:right}]
	end
end