class PaymentAdvicePdf < Prawn::Document
	$LOAD_PATH << '.'
	require 'open-uri'
	include PdfBase
	def initialize(date, users, payroll_detail, account, company)
		super(:page_layout=>:portrait, :paper_size=>"A4", :top_margin=>10, :left_margin=>10, :right_margin=>20)
		@date=date
		@users=users
		@payroll_detail=payroll_detail
		@account=account
		@company=company
		generate_pdf
	end

	def generate_pdf
		bounding_box([0, cursor], :width=>bounds.width) do 
			company_name_and_address_in_center
			stroke_horizontal_rule
		end
		bounding_box([0, cursor-10], :width=>bounds.width) do 
			text_to_bank_manager
		end
		bounding_box([0, cursor-10], :width=>bounds.width) do
			user_salary_details
		end

		bounding_box([0, cursor-10], :width=>bounds.width) do 
			text "Yours Sincerely", :size => 10
			text "<b>For #{@company.name }</b>", :inline_format => true, :size => 10
			self.y-=20
			text "Authorised Signatory", :size => 10
		end

		page_footer
	end

	def text_to_bank_manager
		text "The Manager", :size => 10
		text "#{@account.accountable.bank_name unless @account.accountable_type == "CashAccount"|| @account.accountable.bank_name.blank?}", :size => 10
		self.y=y-10
		text "Dear Sir ,", :size => 10
		text "<u><b>Payment Advice from #{@company.name} A/C #{@account.name } for #{@date.strftime("%B-%Y")}</b></u>", :inline_format => true,:indent_paragraphs =>20, :size => 10
		text "Please make the payroll tranfer from above account to the below mentioned account numbers 
		employee salaries", :size => 10
	end

	def user_salary_details
		amount=0
		data=[["Sl.No.","Name of the Employee","Account No.","Bank Name","Branch",{:content=>"Amount (#{@company.currency_code})", :align=>:right}]]
		i=1
		@users.each_with_index do |user, index|
			data<<[(index+1),"#{user.full_name}","#{user.get_bank_account_number}","#{user.get_bank_name}","#{user.get_branch}",{:content=>"#{net_amount=user.net_salary(@date)}", :align=>:right}]
			amount+=net_amount
			i+=1
		end
		data<<["","","","","Total",{:content=>"#{amount}", :align=>:right}]
		table(data, :header => true, :width => bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 50, 2 => 80, 3 => 80, 4 => 80}) do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.1
			row(0).font_style = :bold
			row(i).column(4..5).borders = [:top, :bottom]
			row(i).column(4..5).border_width = 0.1
		end
	end
end