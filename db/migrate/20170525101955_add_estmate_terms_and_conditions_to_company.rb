class AddEstmateTermsAndConditionsToCompany < ActiveRecord::Migration
  def change
  	add_column :companies, :estimate_terms_and_conditions, :text
  end
end
