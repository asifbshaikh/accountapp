class CreateEstimateSequences < ActiveRecord::Migration
  def change
    create_table :estimate_sequences do |t|
      t.integer :company_id, :null=> false
      t.integer :estimate_sequence, :default=>0

      t.timestamps
    end
  end
end
