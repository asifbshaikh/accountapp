class AddColumnsToEmailTemplates < ActiveRecord::Migration
  def change
    add_column :email_templates, :company_id, :integer
    add_column :email_templates, :email, :string
  end
end
