class CreateBankStatementHeaders < ActiveRecord::Migration
  def change
    create_table :bank_statement_headers do |t|
    	t.integer :bank_id
    	t.integer :company_id
    	t.string :header_1
    	t.string :header_2
    	t.string :header_3
    	t.string :header_4
    	t.string :header_5
    	t.string :header_6
    	t.string :header_7
    	t.string :header_8
    	t.string :date_format
      t.timestamps
    end
  end
end
