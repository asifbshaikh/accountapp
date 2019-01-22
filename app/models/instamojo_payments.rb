class InstamojoPayments < ActiveRecord::Base
	

	def self.add_key(params,account_name)
		 account=InstamojoPayments.new
		 account.company_id=params[:id]
		 account.account_name=account_name
		 account.api_key=params[:paysetting][:apikey]
		 account.auth_key=params[:paysetting][:authkey]
		 account.salt_key=params[:paysetting][:saltkey]
		 account.account_id=params[:account_id]
		 account.status="Active"
		 account.save!

	end

end
