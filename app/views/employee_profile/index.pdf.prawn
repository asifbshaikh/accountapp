
pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')

pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
	pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
	pdf.text "22 Unifed apartment,camp, Pune(MH).", :align => :center, :inline_format => true
    pdf.text "<u>Profile</u>", :align => :center, :inline_format => true
    pdf.text "1-April-2010 to 31-March-2011", :align => :center, :inline_format => true
	pdf.text "<b>#{@current_user.first_name } #{@current_user.last_name}</b>", :inline_format => true
    pdf.stroke_horizontal_rule
end
       
pdf.move_down 10
pdf.text "<u>1. Basic information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10

pdf.table([ ["Under",":#{@department.name  unless @department.nil? }"],
          ["Employee Number", ":#{@current_user.id }"],
          ["Date Of Joining", ":#{@user_salary_detail.date_of_joining unless @user_salary_detail.nil?}"],
          ["Designation", ":#{@designation.title unless @designation.nil?}"],
          ["Function", ":#{@user_salary_detail.work_type unless @user_salary_detail.nil?}"]
          ],  :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])
               
pdf.move_down 20
pdf.text "<u>2.General Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Location",":#{@user_salary_detail.work_location unless @user_salary_detail.nil? }"],
          ["Gender", ":#{@user_information.gender unless @user_information.nil?}"],
          ["Date Of Birth ", ":#{@user_information.birth_date unless @user_information.nil?}"],
          [" Blood Group", ":#{@user_information.blood_group unless @user_information.nil?}"],
          ["Father/Mother Name", ":"],
          ["Spouse Name", ":"]
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"]) 
          
pdf.move_down 20
pdf.text "<u>3.Bank Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Bank Name",":#{@user_salary_detail.bank_name unless @user_salary_detail.nil? }"],
          ["Branch", ":#{@user_salary_detail.branch unless @user_salary_detail.nil?}"],
          [" Bank A/c Number ", ":#{@user_salary_detail.bank_account_number unless @user_salary_detail.nil?}"]
          
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])    
          
          
pdf.move_down 20
pdf.text "<u>4.Contact Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Contact Number",":#{@user_information.emergency_contact unless @user_information.nil? }"],
          ["Address", ":#{@user_information.present_address unless @user_information.nil?}"],
          [" E-Mail ID ", ":#{@current_user.email}"]
          
          ],:width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])
          
          
pdf.move_down 20
pdf.text "<u>5.Separation Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Date of Resignation/Retirement",":"],
          ["PF Date of Releiving", ":"],
          [" Reasons for Leaving ", ":"]
          
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])
          
           
pdf.move_down 20
pdf.text "<u>6.Passport & Visa Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Passport Number",":#{@user_information.passport_number unless @user_information.nil? }"],
          ["Country Of Issue", ":"],
          ["Passport Expiry Date ", ":#{@user_information.passport_expiry_date unless @user_information.nil?}"],
          [" Visa Number", ":"],
          ["Visa Expiry Date", ":"],
          ["Spouse Name", ":"]
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])
          
pdf.move_down 20
pdf.text "<u>7.Contract Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Work Permit Number",":"],
          ["Contract Start Date", ":"],
          ["Contract Expiry Date ", ":"]
         
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])
          
pdf.move_down 20
pdf.text "<u>8.Statutory Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Income Tax Number(PAN)",":#{@user_salary_detail.PAN  unless @user_salary_detail.nil? }"],
          ["PF Account Number", ":#{@user_salary_detail.PF_account_number unless @user_salary_detail.nil? }"],
          ["EPS Account Nubmer ", ":#{@user_salary_detail.EPS_account_number unless @user_salary_detail.nil?}"],
          ["PF Date Of Joining", ":"],
          [" ESI Number", ":"],
          ["ESI Dispensary Name", ":"]
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])
                 
pdf.move_down 20

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
