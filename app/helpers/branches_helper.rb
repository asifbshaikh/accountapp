module BranchesHelper

  def branch_address
    @branch.address.address_line1 + " #{@branch.address.address_line2}" unless @branch.address.blank?
  end

  def branch_city
    @branch.address.city unless @branch.address.blank? && @branch.address.city.blank?
  end

  def branch_pincode
    @branch.address.postal_code unless @branch.address.blank? && @branch.address.postal_code.blank?
  end

end
