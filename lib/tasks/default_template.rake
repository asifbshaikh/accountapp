namespace :default_template do

task :create_template => :environment do
  template_names = ["Classic","Modern1", "Thermal", "Tabular"]
  template_names.each do |name|
    template = Template.find_by_voucher_type_and_template_name("Invoice", name)
      if template.blank?
      template = Template.new
      template.template_name = name
      template.voucher_type = "Invoice"
      template.save!
      puts"@@ default template #{template.template_name} created "
      else
      puts"@@@ already default template  #{template.template_name} created"
      end
   end

    @companies = Company.where("created_at >= '2016-04-28'")
    @companies.each do |company|
    @template = Template.find_by_voucher_type_and_template_name("Invoice","Classic")
    company_template = CompanyTemplate.find_by_company_id_and_voucher_type_and_template_id(company.id, "Invoice" ,@template.id)
            if !@template.blank? && company_template.blank?
            company_template = CompanyTemplate.new
            company_template.company_id = company.id
            company_template.template_id = @template.id
            company_template.voucher_type = "Invoice"
            company_template.save!
            puts"@@ company template created for #{company.name}"
            else
            puts"@@@ company #{company.name} already has #{@template.template_name} as default"
            end
     end

end

end


