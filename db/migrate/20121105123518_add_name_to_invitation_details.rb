class AddNameToInvitationDetails < ActiveRecord::Migration
  def self.up
    add_column :invitation_details, :name, :string
  end

  def self.down
    remove_column :invitation_details, :name
  end
end
