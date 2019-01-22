class AddDueDateToGstrTwo < ActiveRecord::Migration
  def change
    add_column :gstr_twos, :due_date, :date
  end
end
