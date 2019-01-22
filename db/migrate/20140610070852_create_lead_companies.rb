class CreateLeadCompanies < ActiveRecord::Migration
  def change
    create_table :lead_companies do |t|
      t.integer :lead_id
      t.integer :company_id

      t.timestamps
    end
  end
end
