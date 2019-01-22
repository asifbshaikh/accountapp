
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
pdf.text "<u>Breakup By Employee</u>", :align => :center, :inline_format => true
pdf.text "For month : <b> #{@date.strftime("%B %Y")}</b>", :align => :center, 
         :inline_format => true
pdf.move_down 40
      @payhead_names = []
      @payhead_names << "Employee Names"
      @payheads.each do |payhead|
      @payhead_names << payhead.payhead_name
      end
      @payhead_names << "Total"+" (#{@company.currency_code})"
      @payhead_names.join(",")
       data = ([@payhead_names])


                  @users.each do |u|
                  users_salary = u.get_salary
                  @net_salary=0
                 
                
                   
                   @salary_amount = []
                   @salary_amount << u.full_name
                   @payheads.each do |p|
                     salary = p.salary_breakage(u.id, @date)
                     if salary.blank?
                       @salary_amount << "0.00"
                     else
                       @salary_amount << salary.amount
                       @net_salary +=p.payhead_type!="Earnings" ? -1*salary.amount : salary.amount
                     end
                   end
                 @salary_amount << @net_salary
                 @salary_amount.join(",")
                   data += ([@salary_amount])
                  
                end





pdf.table(data, :header => true, :width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {1 => 60})do
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
