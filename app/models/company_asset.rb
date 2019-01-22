class CompanyAsset < ActiveRecord::Base
  set_table_name "assets"
  belongs_to :user
  belongs_to :company

  #validation start
  validates_presence_of :asset_tag, :purchase_date, :assigned_to

  #validates_format_of :asset_tag, :with => /^[a-zA-Z]/, :message =>"should not contain digit or special chars"
  validate :pdate

  def pdate
    if !purchase_date.blank? && Time.zone.now.to_date < purchase_date
      errors.add(:purchase_date,"should be less than or equal to today's date")
    end
  end

  def self.my_asset
    CompanyAsset.order("purchase_date ASC")
  end

end
