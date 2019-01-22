class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string    :name, :null => false
      t.string    :subdomain, :null => false
      t.string    :pan, :limit => 10
      t.string    :sales_tax_no, :limit => 100
      t.string    :tin, :limit => 100
      t.date      :activation_date, :null => false
      t.date      :expiry_date
      t.boolean   :reminder	
      t.integer   :active, :limit => 3
      t.boolean   :deleted, :default => false
      t.datetime  :deleted_datetime
      t.string    :deleted_by
      t.text      :deleted_reason
      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
