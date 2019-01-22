class AddStateCodeAndCapitalToStates < ActiveRecord::Migration
  def change
    add_column :states, :state_code, :integer
    add_column :states, :capital, :string
  end
end
