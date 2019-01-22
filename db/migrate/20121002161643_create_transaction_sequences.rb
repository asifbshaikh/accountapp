class CreateTransactionSequences < ActiveRecord::Migration
  def self.up
    create_table :transaction_sequences do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :transaction_sequences
  end
end
