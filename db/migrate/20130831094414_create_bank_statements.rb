class CreateBankStatements < ActiveRecord::Migration
  def change
    create_table :bank_statements do |t|
      t.integer :company_id
      t.integer :created_by

      t.timestamps
    end
  end
end
