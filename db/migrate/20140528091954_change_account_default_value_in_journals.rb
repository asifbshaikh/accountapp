class ChangeAccountDefaultValueInJournals < ActiveRecord::Migration
  def change
    change_column :journals, :account_id, :integer, :null=> true
  end
end
