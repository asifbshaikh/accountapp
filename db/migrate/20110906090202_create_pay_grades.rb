class CreatePayGrades < ActiveRecord::Migration
  def self.up
    create_table :pay_grades do |t|
      t.integer :user_id, :null => false
      t.integer :company_id, :null => false
      t.integer :job_id, :null => false
      t.string :grade_name, :null => false
      t.text :description, :limit => 500
      t.decimal :amount, :precision => 18, :scale => 2, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :pay_grades
  end
end
