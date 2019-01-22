class CreateEmailTemplates < ActiveRecord::Migration
  def self.up
    create_table :email_templates do |t|
      t.string :template_name
      t.string :subject
      t.string :header
      t.string :body
      t.string :footer
      t.integer :created_by

      t.timestamps
    end
  end

  def self.down
    drop_table :email_templates
  end
end
