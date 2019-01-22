class CreateGstr2Summaries < ActiveRecord::Migration
   def change
    create_table :gstr2_summaries do |t|
      t.integer :company_id, :null => false
      t.integer :gstr_two_id, :null => false
      t.string :summary_type, :limit =>2
      t.string :return_period, :limit => 6
      t.string :chksum, :limit => 64
      t.integer :status, :limit => 2
      t.timestamps
    end
  end
end
