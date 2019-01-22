class JournalLineItem < ActiveRecord::Base
  scope :by_company, lambda { |company| includes(:journal).where(journals: {company_id: company}) }
  scope :by_account, lambda { |account| where(from_account_id: account)  }
  scope :by_date_range, lambda { |start_date, end_date| where(journals: {date: start_date..end_date}) }
  
  belongs_to :journal
  belongs_to :account, :foreign_key=>:from_account_id
  #validation
  validates_presence_of :from_account_id, :amount, :credit_amount
  
  class << self
    def for_customer_as_on_date(company, customer, start_date, end_date)
      start_date = start_date.to_date
      end_date = end_date.blank? ? Time.zone.now.end_of_month.to_date : end_date.to_date
      by_company(company.id).by_account(customer).by_date_range(start_date, end_date)
    end
    def new_journal_line_item(journal_id, from_account_id, amount, credit_amount)
      JournalLineItem.new(:journal_id => journal_id, :from_account_id => from_account_id,
        :amount => amount, :credit_amount => credit_amount)
    end

  end

  def delete_with_ledger
    journal = self.journal
    from_ledger_entry = journal.ledgers.find_by_account_id(from_account_id)
    transaction do
      from_ledger_entry.destroy unless from_ledger_entry.blank?
      destroy
    end
  end
end
