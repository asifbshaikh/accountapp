class CompanyTemplate < ActiveRecord::Base
  belongs_to :company
  belongs_to :template

  def self.create_default_template(company_id)
    template = Template.find_by_voucher_type_and_template_name("Invoice","Classic")
    if !template.blank?
      company_template = CompanyTemplate.new
      company_template.company_id = company_id
      company_template.template_id = template.id
      company_template.voucher_type = "Invoice"
      company_template.save!
     end
  end

  def update_template(template_id)
    self.update_attribute(:template_id, template_id.to_i)
  end


end
