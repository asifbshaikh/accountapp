class CreateInvitationDetails < ActiveRecord::Migration
  def self.up
    create_table :invitation_details do |t|
      t.integer :company_id, :null => false
      t.integer :sent_by, :null => false
      t.string :email, :null => false, :limit => 100
      t.string :token, :null => false, :limit => 10
      t.integer :status_id, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :invitation_details
  end
end
