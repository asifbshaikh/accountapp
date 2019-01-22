class CreateTableMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :subject 
      t.text :description
      t.integer :created_by, :null => false
      t.integer :user_id,:null => false 
      t.integer :company_id, :null => false
      t.integer :status , :null => false 
       
      t.timestamps
  end

  def self.down
    drop_table :messages
  end
  end
end
