class CreateTableGstr1CounterPartySummaries < ActiveRecord::Migration
  def up
  	create_table :gstr1_counter_party_summaries do |t|
      t.integer :gstr1_section_summary_id, :null => false
      t.string :ctin, :limit => 15
      t.string :chksum, :limit => 64
      t.integer :total_record, :default => 0
      t.decimal	:total_value, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_igst, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_cgst, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_sgst, :precision => 18, :scale => 2, :default => 0
      t.decimal :total_cess, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_taxable_value, :precision => 18, :scale => 2, :default => 0
      t.timestamps
    end
  end

  def down
  end
end
