class CreateTemplates < ActiveRecord::Migration
  def self.up
    create_table :templates do |t|
      t.string :template_name
      t.string :voucher_type, :null=> false
      t.boolean :deleted, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :templates
  end
end
