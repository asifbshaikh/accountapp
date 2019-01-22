class ChangeDataTypeForPaymentLink < ActiveRecord::Migration
  def up

  	change_table :instamojo_payment_links do |t|
      t.change :payment_request_id, :string
    end
  end

  def down
  	change_table :instamojo_payment_links do |t|
      t.change :payment_request_id, :int
    end
  end
end
