class AddTermsAndConditionsAndCustomerNoteToCompanies < ActiveRecord::Migration
  def self.up
  	 add_column :companies, :terms_and_conditions, :string
  	 add_column :companies, :customer_note, :string
  end

  def self.down
  	remove_column :companies, :terms_and_conditions
  	remove_column :companies, :customer_note
  end
end
