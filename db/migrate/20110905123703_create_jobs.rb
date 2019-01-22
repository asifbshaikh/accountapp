class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.integer :user_id, :null => false
      t.integer :company_id, :null => false
      t.string :title, :null => false
      t.text :description, :limit => 500
      t.string :status
      t.date :joining_date

      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
