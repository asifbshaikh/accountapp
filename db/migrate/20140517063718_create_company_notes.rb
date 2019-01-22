class CreateCompanyNotes < ActiveRecord::Migration
  def change
    create_table :company_notes do |t|
      t.integer :company_id
      t.text :description
      t.integer :created_by

      t.timestamps
    end
  end
end
