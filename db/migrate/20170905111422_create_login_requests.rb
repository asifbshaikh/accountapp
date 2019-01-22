class CreateLoginRequests < ActiveRecord::Migration
  def change
    create_table :login_requests do |t|
      t.integer :company_id
      t.integer :created_by
      t.integer :status
      t.string :calling_action
      t.integer :gsp_id

      t.timestamps
    end
  end
end
