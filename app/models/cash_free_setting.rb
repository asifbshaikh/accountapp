class CashFreeSetting < ActiveRecord::Base

	def self.add_key(params)
		 account=CashFreeSetting.new
		 account.company_id=params[:id]
		 account.app_id=params[:cashfreesetting][:appid]
		 account.secret_key=params[:cashfreesetting][:secretkey]
		 account.account_id=params[:account_id]
		 account.expense_account=params[:expense_account]
		 account.expense_tax_account=params[:expensetaxacc]
		 account.status="Active"
		 account.save!

	end
end
