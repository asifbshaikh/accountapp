class AddColumnsToSundryDebtors < ActiveRecord::Migration
  def self.up
  	add_column :sundry_debtors, :website, :string
  	add_column :sundry_debtors, :fax, :string, :limit => 12
  	add_column :sundry_debtors, :country, :string, :limit => 100
  	add_column :sundry_debtors, :weekly_off, :string, :limit => 10
  	add_column :sundry_debtors, :cin_code, :string, :limit => 25
  	add_column :sundry_debtors, :bank_name, :string
  	add_column :sundry_debtors, :ifsc_code, :string, :limit => 25
  	add_column :sundry_debtors, :micr_code, :string, :limit => 25
  	add_column :sundry_debtors, :bsr_code, :string, :limit => 25
  	add_column :sundry_debtors, :credit_days, :integer
  	add_column :sundry_debtors, :credit_limit, :integer, :precision => 18, :scale => 2
  	add_column :sundry_debtors, :date_of_incorporation, :date
  	add_column :sundry_debtors, :open_time, :integer, :precision => 5, :scale => 2
  	add_column :sundry_debtors, :close_time, :integer, :precision => 5, :scale => 2
  end

  def self.down
  	remove_column :sundry_debtors, :website
  	remove_column :sundry_debtors, :fax
  	remove_column :sundry_debtors, :country
  	remove_column :sundry_debtors, :weekly_off
  	remove_column :sundry_debtors, :cin_code
  	remove_column :sundry_debtors, :bank_name
  	remove_column :sundry_debtors, :ifsc_code
  	remove_column :sundry_debtors, :micr_code
  	remove_column :sundry_debtors, :bsr_code
  	remove_column :sundry_debtors, :credit_days
  	remove_column :sundry_debtors, :credit_limit
  	remove_column :sundry_debtors, :date_of_incorporation
  	remove_column :sundry_debtors, :open_time
  	remove_column :sundry_debtors, :close_time
  end
end
