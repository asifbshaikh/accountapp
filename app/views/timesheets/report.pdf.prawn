
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
if @user_id.blank?
pdf.text "<u>Timesheet Report For All Employees</u>", :align => :center, :inline_format => true
else
pdf.text "<u>Timesheet Report</u>", :align => :center, :inline_format => true
pdf.text "For Employee : <b> #{User.find(@user_id).full_name}</b>", :align => :center, 
         :inline_format => true
end
pdf.text "For Period : <b> #{@start_date} - #{@end_date.to_date}</b>", :align => :center, 
         :inline_format => true
pdf.move_down 40
      data = [['Project', 'Task', 'Assigned To', 'Assigned Date', 'Completed Date', 'Time (hrs)']]

@tasks.each do |task|
      @timesheet_record = []
      @timesheet_record << task.get_project(task.id)
      @timesheet_record << task.description
      @timesheet_record << task.assigned_user
      @timesheet_record << task.created_at.to_date
      @timesheet_record << task.completed_date
      @timesheet_record << task.get_total_timestamp(task.id)
      @timesheet_record.join(",")
      data += ([@timesheet_record])
      end

pdf.table(data, :header => true, :width => pdf.bounds.width, :row_colors => ["FFFFFF","F2F7FF"], :cell_style =>{:border_width => 0, :border_color => "70B8FF", :size => 9}, :column_widths => {0 => 60,1 => 120})do
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
