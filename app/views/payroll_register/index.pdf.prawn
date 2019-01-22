
require 'prawn'
require 'rubygems'
require 'prawn/security'
require 'prawn/layout'
require 'enumerator'

pdf = Prawn::Document.new(:page_layout => :landscape, :page_size => 'A4')
pdf.text "<b>#{Company.find(@company).name  unless Company.find(@company).nil?}</b>", :align => :center, :inline_format => true, :size =>20
        pdf.text "22 Unifed apartment' 2407 East street,camp, Pune(MH). pin:411001", :align => :center, :inline_format => true
		pdf.text "<u>Pay Sheet</u>", :align => :center, :inline_format => true
		pdf.text "1-April-2010 to 31-March-2011", :align => :center, :inline_format => true
		pdf.move_down 20
        pdf.stroke_horizontal_rule
        pdf.move_down 50




pdf.table([ ["Date","P a r t i c u l a r s","Vch Type","Vch No.","Debit Amount ","Credit Amount  "],
             ["30-4-2010","Special Incentives ","Payroll","1","345334",""],
             ["","Salary Payable Pay Period: 1-Apr-2010 to 30-Apr-2010","","","","5345"],
             ["30-4-2010","	Employer's PF Contribution@8.33% ","Payroll","2","345334",""],
             ["","Employer's PF Contribution@3.37%","","","9899",""],
             ["","PF Payable Pay Period: 1-Apr-2010 to 30-Apr-2010","","","","6876"],
             ["30-4-2010","	Basic Salary ","Payroll","3","345334",""],
             ["","Dearness Allowance ","","","6566",""],
             ["","Convayance Allowance ","","","5656",""],
             ["","Employee PF Contribution@12%","","","","7778"],
             ["","TDS","","","","7778"]], 
             :column_widths => {1 => 200}, :cell_style => {:border_width => 0, :border_color =>"70B8FF"}, :row_colors => [ "ffffff","F2F7FF"],:width => 700)do
             row(0..1).borders = [:top]
		     row(0..1).border_width = 1
		     end

                   
pdf.move_down 10
creation_date = Time.zone.now.strftime('%d-%m-%Y')
pagecount = pdf.page_count
Prawn::Document.generate("footer.pdf", :skip_page_creation => true) do

pdf.page_count.times do |i|

pdf.go_to_page(i+1)
pdf.fill_color "FF0000"

pdf.draw_text "This page is generated by www.profitbooks.net", :at=>[0,-10], :size => 10
pdf.draw_text "Page Count : #{i+1} / #{pdf.page_count}", :at=>[600,-10]

end

end
 pdf.render_file('prawn.pdf')
