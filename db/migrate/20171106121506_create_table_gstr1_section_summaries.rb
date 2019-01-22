class CreateTableGstr1SectionSummaries < ActiveRecord::Migration
  def up
  	create_table :gstr1_section_summaries do |t|
      t.integer :gstr1_summary_id, :null => false
      t.string :section_type, :limit => 20 ,:null => false
      t.string :chksum, :limit => 64
      t.integer :total_record, :default => 0
      t.decimal	:total_value, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_igst, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_cgst, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_sgst, :precision => 18, :scale => 2, :default => 0
      t.decimal :total_cess, :precision => 18, :scale => 2, :default => 0
      t.decimal	:total_taxable_value, :precision => 18, :scale => 2, :default => 0
      t.decimal :nil_supply_amt, :precision => 18, :scale => 2, :default => 0
      t.decimal :exempted_supply_amt, :precision => 18, :scale => 2, :default => 0
      t.decimal :ngsup_outward_amt, :precision => 18, :scale => 2, :default => 0
      t.integer :total_doc_issued, :default => 0
      t.integer :total_doc_cancelled, :default => 0
      t.integer :net_doc_issued, :default => 0
      t.timestamps
    end
  end

  def down
  end
end
