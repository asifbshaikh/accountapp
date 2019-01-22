class JournalToLineItem < ActiveRecord::Base
  belongs_to :journal
  #validations
  validates_presence_of :to_account_id, :amount
  validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
  validates :to_account_id, :uniqueness => { :scope => :journal_id, :message => "should once per journal entry" }

   def delete_with_ledger
	journal = self.journal
	
	to_ledger_entry = journal.ledgers.find_by_account_id(to_account_id)
	transaction do
		to_ledger_entry.destroy unless to_ledger_entry.blank?
		destroy
	end
  end
end
