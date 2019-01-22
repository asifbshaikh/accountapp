class SaccountingLineItem < ActiveRecord::Base
  belongs_to :saccounting
  
  #validation
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
  validates :from_account_id, :presence => true #:uniqueness => { :scope => :saccounting_id, :message => "should once per simple accounting entry" }

 def delete_with_ledger
	saccounting = self.saccounting
	puts "hiiiiii delete with ledger"
	from_ledger_entry = saccounting.ledgers.find_by_account_id(from_account_id)
	transaction do
		from_ledger_entry.destroy unless from_ledger_entry.blank?
		destroy
	end
  end
                                        
end
