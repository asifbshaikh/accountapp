
pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')

pdf.bounding_box([0,pdf.cursor], :width => pdf.bounds.width, :height =>80) do
	pdf.text "<b>#{@company.name }</b>", :align => :center, :inline_format => true, :size =>14
	pdf.text "22 Unifed apartment,camp, Pune(MH).", :align => :center, :inline_format => true
    pdf.text "<u>Profile</u>", :align => :center, :inline_format => true
    pdf.text "1-April-2010 to 31-March-2011", :align => :center, :inline_format => true
	pdf.text "<b>#{@users.first_name } #{@users.last_name}</b>", :inline_format => true
    pdf.stroke_horizontal_rule
end
       
pdf.move_down 10
pdf.text "<u>1. Basic information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10

pdf.table([ ["Under",":#{@departments.name  unless @departments.nil? }"],
          ["Employee Number", ":#{@users.id unless @users.nil?}"],
          ["Date Of Joining", ":#{@user_salary_details.date_of_joining unless @user_salary_details.nil?}"],
          ["Designation", ":#{@designations.title unless @designations.nil?}"],
          ["Function", ":#{@user_salary_details.work_type unless @user_salary_details.nil?}"]
          ],  :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])
               
pdf.move_down 20
pdf.text "<u>2.General Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Location",":#{@user_salary_details.work_location unless @user_salary_details.nil? }"],
          ["Gender", ":#{@user_informations.gender unless @user_informations.nil?}"],
          ["Date Of Birth ", ":#{@user_informations.birth_date unless @user_informations.nil?}"],
          [" Blood Group", ":#{@user_informations.blood_group unless @user_informations.nil?}"],
          ["Father/Mother Name", ":"],
          ["Spouse Name", ":"]
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"]) 
          
pdf.move_down 20
pdf.text "<u>3.Bank Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Bank Name",":#{@user_salary_details.bank_name unless @user_salary_details.nil? }"],
          ["Branch", ":#{@user_salary_details.branch unless @user_salary_details.nil?}"],
          [" Bank A/c Number ", ":#{@user_salary_details.bank_account_number unless @user_salary_details.nil?}"]
          
          ], :width => 600, :cell_style => {:border_width => 0}, :row_colors => [ "ffffff","F2F7FF"])    
          
          
pdf.move_down 20
pdf.text "<u>4.Contact Information</u>", :align => :left, :inline_format => true, :indent_paragraphs => 20
pdf.move_down 10
pdf.table([ ["Contact Number",":#{@user_informations.emergency_contact unless @user_informations.nil? }"],
          ["Address", ":#{@user_informations.present_address unless @user_informations.nil?}"],
          [" E-Mail ID ", ":#{@users.email unless @users.nil?}"]
          
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
pdf.table([ ["Passport Number",":#{@user_informations.passport_number unless @user_informations.nil? }"],
          ["Country Of Issue", ":"],
          ["Passport Expiry Date ", ":#{@user_informations.passport_expiry_date unless @user_informations.nil?}"],
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
pdf.table([ ["Income Tax Number(PAN)",":#{@user_salary_details.PAN  unless @user_salary_details.nil? }"],
          ["PF Account Number", ":#{@user_salary_details.PF_account_number unless @user_salary_details.nil? }"],
          ["EPS Account Nubmer ", ":#{@user_salary_details.EPS_account_number unless @user_salary_details.nil?}"],
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
			pdf.draw_text "Generated from www.profitnext.com", :at=>[0,-10], :size => 7
			pdf.fill_color "000000"
			pdf.draw_text "Page : #{i+1} / #{pdf.page_count}", :at=>[pdf.bounds.width - 50,-10], :size => 9
		end
	end



