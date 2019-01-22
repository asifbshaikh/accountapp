class CreateOrganisationAnnouncements < ActiveRecord::Migration
  def self.up
    create_table :organisation_announcements do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :title, :null => false
      t.text :announcement
      
      t.timestamps
    end
  end

  def self.down
    drop_table :organisation_announcements
  end
end
