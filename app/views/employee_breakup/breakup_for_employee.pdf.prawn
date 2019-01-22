require 'prawn'
require 'rubygems'
require 'prawn/security'
require 'prawn/layout'
require 'enumerator'

pdf = Prawn::Document.new(:page_layout => :landscape, :page_size => 'A4')
pdf.text "<b>#{@company.name}</b>", :align => :center, :inline_format => true, :size =>20
pdf.text "#{@company.address.get_address unless @company.address.blank?}", :align => :center, :inline_format => true

pdf.move_down 10
pdf.stroke_horizontal_rule
pdf.move_down 10
pdf.text "<u>Breakup For Employee</u>", :align => :center, :inline_format => true
pdf.text "For Employee : <b> #{User.find(@user_id).full_name}</b>", :align => :center, 
         :inline_format => true
pdf.move_down 40
				@payhead_names = []
				@payhead_names << "Payheads"
				@months.uniq!.each do |m|
                @payhead_names << m.strftime("%b-%y")
                end

                @payhead_names << "Total"+" (#{@company.currency_code})"
                data = ([@payhead_names])

                @payheads.each do |p|
                @total = 0

                @salary_amount = []
                @salary_amount << p.payhead_name

                @months.each do |m|
                str = "#{m.strftime("%Y-%m")}"+"-01"
                    @date1 = Date.parse(str) 
                salary = Salaries.where("payhead_id = ? and user_id = ? and company_id = ? and month between ? and ?",p.id,@user_id,@company.id,@date1.beginning_of_month, @date1.end_of_month)
                  
                
                    salary.each do |s|
                   @salary_amount << s.amount
                    @total += s.amount
                  end
                  if salary.blank?
                   @salary_amount << "0.00"
                   end

                end

                @salary_amount << @total
                @salary_amount.join(",")
                data += ([@salary_amount]) 

                end



pdf.table(data, :header => true, :width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9})do
    row(0).borders = [:top, :bottom]
    row(0).border_width = 0.1
    row(0).font_style = :bold
    
  end



pdf.move_down 10
creation_date = Time.zone.now.strftime('%d-%m-%Y')
pagecount = pdf.page_count
Prawn::Document.generate("footer.pdf", :skip_page_creation => true) do
  pdf.page_count.times do |i|
    pdf.go_to_page(i+1)
    pdf.fill_color "ADADAD"
    pdf.draw_text "Generated from www.profitbooks.net", :at=>[0,-10], :size => 7
    pdf.fill_color "000000"
    pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
  end
end