class CreateCompanyTemplates < ActiveRecord::Migration
  def self.up
    create_table :company_templates do |t|
      t.integer :company_id, :null => false
      t.integer :template_id, :null => false
      t.string :voucher_type, :null=> false

      t.timestamps
    end
  end

  def self.down
    drop_table :company_templates
  end
end
