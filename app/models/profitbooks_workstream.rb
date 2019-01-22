class ProfitbooksWorkstream < ActiveRecord::Base

  default_scope order('release_date DESC')

  FEATURES = {:Dashboard => 0, :Invoices => 1, :Receipts => 2, :Estimates => 3, :Customers => 4, 
    :SalesOrders => 5, :Expenses => 6, :Purchases => 7, :Payments => 8, :Vendors => 9,
    :Banking => 10, :GeneralAccounting => 11, :Inventory => 12, :Payroll => 13, :Reports => 14,
    :GeneralEnhancements => 15
  }

  STATUS = {:draft => 0, :published =>1, :archived => 2}

  validates_presence_of :feature_id, :icon_code, :release_date, :title
  validates :link_URL, :format => URI::regexp(%w(http https)), :if => "link_URL.present?"

  class << self
    
    def published_updates
      self.where("status = ?", STATUS[:published])
    end

    def new_updates
      @updates = self.where("status = ?", STATUS[:published]).where("Date(release_date) between ? and ? ", (Time.zone.now.to_date - 3.days), Time.zone.now.to_date).limit(1)
      @updates.present? ? @updates : nil
    end
    
  end

  def feature_name
    FEATURES.key(self.feature_id)
  end

  def published?
    status == STATUS[:published]
  end

  def archived?
    status == STATUS[:archived]
  end


  def publish()
    self.update_attribute(:status, STATUS[:published])
  end

  def archive()
    self.update_attribute(:status, STATUS[:archived])
  end

end
