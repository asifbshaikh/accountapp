class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.integer :company_id, :null => false
      t.integer :created_by, :null => false
      t.string :subject 
      t.text :description
      t.integer :status 
       
      t.timestamps
  end

  def self.down
    drop_table :notes
  end
  end
end
