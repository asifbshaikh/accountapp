class ProfitLossPdf < Prawn::Document
	include ApplicationHelper
	include HorizontalProfitAndLossHelper
	include ActionView::Helpers::NumberHelper
	def initialize(view_context, company, end_date, branch_id, opening_stock_valuation,
					direct_expense_with_sub_heads, desh_hash, indirect_expense_with_sub_heads, iewsh_hash,
          direct_income_with_sub_heads, diwsh_hash, indirect_income_with_sub_heads, iiwsh_hash,
          inventory_valuation, net_profit, total_expense, total_income)
		super(:page_layout => :portrait, :page_size => "A4", :top_margin=>10, :left_margin=>10, :right_margin=>20)
		@view_context=view_context
		@company=company
		#@start_date=start_date
		@end_date=end_date
		@opening_stock_valuation=opening_stock_valuation
		@direct_expenses_with_sub_heads=direct_expense_with_sub_heads
		@direct_expenses_hash=desh_hash
		@indirect_expenses_with_sub_heads=indirect_expense_with_sub_heads
		@indirect_expenses_hash=iewsh_hash
		@direct_income_with_sub_heads=direct_income_with_sub_heads
		@direct_income_hash=diwsh_hash
		@indirect_income_with_sub_heads=indirect_income_with_sub_heads
		@indirect_income_hash=iiwsh_hash
		@inventory_valuation=inventory_valuation
		@net_profit=net_profit
		@total_expense=total_expense
		@total_income=total_income
		generate_pdf
	end

	def generate_pdf
		bounding_box([0,cursor], :width => bounds.width) do
			company_header
		end

		bounding_box([0, cursor-10], :width=>bounds.width) do
			pdf_header
		end
		y_position=cursor-10
		bounding_box([0, y_position], :width=>(bounds.width/2)) do
			expense_info_table
		end

		bounding_box([(bounds.width/2)+5, y_position], :width => ((bounds.width/2)-5)) do
			income_info_table
		end

		page_footer
	end

	def company_header
		text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
		text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :size => 10
	end

	def pdf_header
		text "<b><u>Profit and Loss account</u></b>", :align => :center, :inline_format => true, :size => 12
		text " on date #{ @end_date }",:align => :center, :size => 6
	end

	def income_info_table
		profit_loss_report_table(:header=>"Income", :inventory_valuation=>true, :list=>["Direct Income", "Indirect Income"] )
	end

	def expense_info_table
		profit_loss_report_table(:header=>"Expense", :opening_stock=>true, :list=>["Direct Expenses", "Indirect Expenses"] )
	end

	def profit_loss_report_table(args)
		data=[[{:content => args[:header]},"","",{:content => "as on date #{@end_date}", :align => :right, :size => 10}]]
		data<<[{:content => "Opening stock", :font_style => :bold},"","",{:content=>"#{ format_currency(@opening_stock_valuation)}",:font_style=>:bold, :align=>:right}] if args[:opening_stock]
		item_list=args[:list]
		item_list.each_with_index do |item, index|
			hash=eval "@#{item.downcase.to_s.gsub(' ', '_')}_hash"
			data<<[{:content => item, :font_style => :bold},"","",{:content=>"#{@company.currency_code} #{args[:header]=="Expense" ? hash.values.sum : clean_output(-1*hash.values.sum)}",:font_style=>:bold, :align=>:right}]
			account_heads=eval "@#{item.downcase.to_s.gsub(' ', '_')}_with_sub_heads"
			account_heads.each do |account_head|
				data<<[account_head.name,"","",{:content=>"#{@company.currency_code} #{args[:header]=="Expense" ? hash[account_head.id] : clean_output(-1*hash[account_head.id])}", :align=>:left}]
			end
		end
		data<<[{:content => "Stock in hand", :font_style => :bold},"","",{:content=>"#{ format_currency(@inventory_valuation)}",:font_style=>:bold, :align=>:right}] if args[:inventory_valuation]
		if args[:header]=="Expense"&&@net_profit >= 0
			data<<[{:content => "Net Profit", :font_style=>:bold},"","",
		       {:content => "#{ format_currency @net_profit.abs }",:font_style=>:bold,:align=>:right}]
		elsif args[:header]=="Income"&&@net_profit<0
			data<<[{:content => "Net Loss", :font_style=>:bold},"","",
			       {:content => "#{ format_currency @net_profit.abs }",:font_style=>:bold,:align=>:right}]
		end
		total=eval "@total_#{args[:header].downcase}"
		data<<[{:content =>"Total", :font_style=>:bold},"","",
            {:content =>"#{ format_currency total }", :font_style=>:bold,:align=>:right}]
		table(data, :header => true, :width => bounds.width,:row_colors => ["FFFFFF","F2F7FF"] , :cell_style => {:border_width => 0, :border_color => "70B8FF", :size => 8}) do
			row(0).borders = [:top, :bottom]
			row(0).border_width = 0.2
			row(0).font_style = :bold
		end
	end

	def page_footer
		page_count.times do |i|
		  go_to_page(i+1)
		  fill_color "ADADAD"
		  if @footer.nil? || @footer.strip == ''
		   draw_text "#{@company.watermark unless @company.watermark.blank?}", :at=>[0,-30], :size => 7
		  else
		    draw_text @footer.strip, :at => [0,-30], :size => 7
		  end
		  fill_color "000000"
		  draw_text "Page : #{i+1} / #{page_count}", :at=>[bounds.width - 50,-30], :size => 8
		end
	end
end
