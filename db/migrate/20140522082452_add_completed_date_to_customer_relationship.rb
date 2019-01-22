class AddCompletedDateToCustomerRelationship < ActiveRecord::Migration
  def change
    add_column :customer_relationships, :completed_date, :date
  end
end
