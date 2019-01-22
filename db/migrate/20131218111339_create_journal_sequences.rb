class CreateJournalSequences < ActiveRecord::Migration
  def change
    create_table :journal_sequences do |t|
      t.integer :company_id, :null=>false
      t.integer :journal_sequence, :default=>0

      t.timestamps
    end
  end
end
