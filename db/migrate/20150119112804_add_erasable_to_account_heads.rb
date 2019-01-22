class AddErasableToAccountHeads < ActiveRecord::Migration
  def change
    add_column :account_heads, :erasable, :boolean, :default=>true
  end
end
