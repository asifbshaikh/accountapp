module PurchaseRegisterHelper

  def display_branch(branch_id)
    if !@branch_id.blank?
      "Branch: <b>#{Branch.find(branch_id).name}</b>"
    end
  end

	def vendor_name(account)
	  @account.blank? ? "All vendors" : @account.name
	end
end
