module AccountsHelper

  def account_address_line1
      @account.accountable.address.address_line1 unless @account.accountable.address.nil?
  end
  
  def account_address_line2
    @account.accountable.address.address_line2 unless @account.accountable.address.nil?
  end

  def account_city
    @account.accountable.address.city unless @account.accountable.address.nil?
  end

  def account_state 
    @account.accountable.address.state unless @account.accountable.address.nil?
  end

  def account_postal_code
    @account.accountable.address.postal_code unless @account.accountable.address.nil?
  end
  
  def depreciable
    @account.accountable.depreciable ? "Yes" : "No"
  end

  def inventoriable
    @account.accountable.inventoriable ? "Yes" : "No"
  end
  
  def reseller_product
    @account.accountable.reseller_product ? "Yes" : "No"
  end

  def auto_calculate_tax
    @account.accountable.auto_calculate_tax ? "Yes" : "No"
  end

  def interest_applicable
    @account.accountable.interest_applicable ? "Yes" : "No"
  end

  def opening_balance
    opening_balance = (@account.opening_balance.blank?)? '0.00' : @account.opening_balance.abs 
    sign = @account.opening_balance >= 0 ? "Dr" : "Cr" unless @account.opening_balance.blank?
    "#{opening_balance} #{sign}"
  end
end
