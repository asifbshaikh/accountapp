class TemplateMargin < ActiveRecord::Base
 has_many :company_templates

 def self.create_default_record(company_id)
	templates = Template.where(:voucher_type =>"Invoice")
	templates.each do |template|
	template_margin = TemplateMargin.new
        template_margin.template_id = template.id
        template_margin.hide_logo = 0
        template_margin.hide_address = 0
        template_margin.top_margin = 10
        template_margin.left_margin = 10
        template_margin.right_margin =20
        template_margin.HideRateQuantity =1
        template_margin.company_id = company_id
        template_margin.save!
     end
 end

end