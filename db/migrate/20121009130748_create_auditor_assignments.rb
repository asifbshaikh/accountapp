class CreateAuditorAssignments < ActiveRecord::Migration
  def self.up
    create_table :auditor_assignments do |t|
      t.integer :auditor_id
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :auditor_assignments
  end
end
