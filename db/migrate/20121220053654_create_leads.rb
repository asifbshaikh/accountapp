class CreateLeads < ActiveRecord::Migration
  def self.up
    create_table :leads do |t|
      t.string :name
      t.string :mobile, :limit => 15
      t.string :email
      t.integer :channel_id
      t.integer :campaign_id
      t.date :next_call_date
      t.text :description
      t.integer :status

      t.timestamps
    end
  end

  def self.down
    drop_table :leads
  end
end
