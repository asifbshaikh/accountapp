module VoucherLineItem
  module ClassMethods
    
  end
  
  module InstanceMethods
    def tax_amount
      tax_amt = 0
      unless (has_attribute?(:quantity) && quantity.blank?) || (has_attribute?(:unit_rate) && unit_rate.blank?)
        tax_accounts.each do |account|
          tax_amt+=account.tax_amount(send("#{self.class.to_s.sub('LineItem', '').underscore}"), self)
        end
      end
      tax_amt
    end

    def igst_amt
      igst_amt = 0
      unless (has_attribute?(:quantity) && quantity.blank?) || (has_attribute?(:unit_rate) && unit_rate.blank?)
        tax_accounts.each do |account|
          if  account.igst_tax_account?
            igst_amt+=account.tax_amount(send("#{self.class.to_s.sub('LineItem', '').underscore}"), self)
          end 
        end
      end
      igst_amt      
    end

    def cgst_amt
      cgst_amt = 0
      unless (has_attribute?(:quantity) && quantity.blank?) || (has_attribute?(:unit_rate) && unit_rate.blank?)
        tax_accounts.each do |account|
          if account.gst_tax_account?
            cgst_amt+=(account.tax_amount(send("#{self.class.to_s.sub('LineItem', '').underscore}"), self))/2
          end 
        end
      end
      cgst_amt      
    end

    def sgst_amt
      sgst_amt = 0
      unless (has_attribute?(:quantity) && quantity.blank?) || (has_attribute?(:unit_rate) && unit_rate.blank?)
        tax_accounts.each do |account|
          if account.gst_tax_account?
            sgst_amt+=(account.tax_amount(send("#{self.class.to_s.sub('LineItem', '').underscore}"), self))/2
          end 
        end
      end
      sgst_amt      
    end

  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end