class CreateUserInformations < ActiveRecord::Migration
  def self.up
    create_table :user_informations do |t|
      t.integer :user_id, :null => false
      t.string :gender
      t.date :birth_date
      t.string :emergency_contact
      t.string :marital_status
      t.string :passport_number
      t.date :passport_expiry_date
      t.date :marriage_date
      t.string :blood_group
      t.string :present_address

      t.timestamps
    end
  end

  def self.down
    drop_table :user_informations
  end
end
