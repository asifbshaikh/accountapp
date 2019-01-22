class AddDueDateToEstimates < ActiveRecord::Migration
  def self.up
    add_column :estimates, :due_date, :date
  end

  def self.down
    remove_column :estimates, :due_date
  end
end
