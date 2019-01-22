class CreateWithdrawalSequences < ActiveRecord::Migration
  def change
    create_table :withdrawal_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :withdrawal_sequence, :default=>0

      t.timestamps
    end
  end
end
