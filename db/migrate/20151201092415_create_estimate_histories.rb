class CreateEstimateHistories < ActiveRecord::Migration
  def change
    create_table :estimate_histories do |t|
    	t.integer :estimate_id
    	t.integer :company_id
    	t.string :description
    	t.integer :created_by
    	t.datetime :record_date
      t.timestamps
    end
  end
end
