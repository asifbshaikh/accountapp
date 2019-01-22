class EmailTemplate < ActiveRecord::Base
  belongs_to :company
 # validates_presence_of :template_name
SOURCE = {'1' => "MCA_RECORD", '2' => "MAHA_TECH"}

  def self.get_email_template(lead)
    unless lead.company.blank?
      emails = EmailTemplate.where(:company_id => lead.company.id).order("created_at DESC")
    end
      emails
  end

end
