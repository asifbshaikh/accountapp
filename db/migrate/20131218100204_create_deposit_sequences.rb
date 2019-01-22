class CreateDepositSequences < ActiveRecord::Migration
  def change
    create_table :deposit_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :deposit_sequence, :default=>0

      t.timestamps
    end
  end
end
