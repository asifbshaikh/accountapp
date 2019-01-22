class CreateSaccountingSequences < ActiveRecord::Migration
  def change
    create_table :saccounting_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :saccounting_sequence, :default=>0

      t.timestamps
    end
  end
end
