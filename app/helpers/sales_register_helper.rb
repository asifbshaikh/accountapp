module SalesRegisterHelper

  def display_branch(branch_id)
    if !@branch_id.blank?
      raw("Branch: <b>#{Branch.find(branch_id).name}</b>")
    end
  end

  def customer_name(account)
    @account.blank? ? "All customers" : @account.name
  end

end
