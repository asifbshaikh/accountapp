class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :title
      t.string :first_name,        :limit => 100
      t.string :last_name,         :limit => 100
      t.string :email ,            :limit => 100
      t.string :gender
      t.date :birthday
      t.date :anniversary
      t.text :address1,            :limit => 255
      t.text :address2,            :limit => 255
      t.string :city
      t.string :state
      t.string :pin_code
      t.string :country
      t.string :phone1,            :limit => 10
      t.string :phone2,            :limit => 10
      t.string  :mobile,           :limit => 10
      t.string  :business_fax,     :limit => 15
      t.string :contact_category
      t.string :designation
      t.string :department
      t.string :company
      t.string :account
      t.text :notes
      t.string :web_page
      t.string :thumbnail
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
