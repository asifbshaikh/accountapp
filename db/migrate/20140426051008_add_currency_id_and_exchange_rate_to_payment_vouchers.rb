class AddCurrencyIdAndExchangeRateToPaymentVouchers < ActiveRecord::Migration
  def change
    add_column :payment_vouchers, :currency_id, :integer
    add_column :payment_vouchers, :exchange_rate, :decimal, :precision => 18, :scale => 5, :default => 0
  end
end
