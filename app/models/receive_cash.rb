class ReceiveCash < ActiveRecord::Base

  belongs_to :account
  has_many :ledgers, :as => :voucher

  #validations
   validates :received_date,:amount,:from_account_id, :deposit_to_account_id, :receipt_mode , :presence=> true
   validates_length_of :description , :maximum => 300
   validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
   validate :from_account_id_and_deposit_to_account_id_validation

   def from_account_id_and_deposit_to_account_id_validation
     if self.from_account_id == self.deposit_to_account_id
        errors.add_to_base("Both accounts should not be same")
     end
  end

  def save_with_ledgers
    save_result = false
    transaction do
      if save
        receive_cashes.each do |receive_cash|
          from_ledger_entry = Ledger.create(:account_id => receive_cash.from_account_id,
            :transaction_date => receive_cash.received_date,
            :debit => receive_cash.amount,
            :voucher_number => receive_cash.voucher_number,
            :created_by => receive_cash.created_by,
            :deleted => false,
            :description => receive_cash.description,
            :corresponding_account_id => receive_cash.deposit_to_account_id)

          to_ledger_entry = Ledger.create(:account_id => receive_cash.deposit_to_account_id,
            :transaction_date => receive_cash.received_date,
            :credit => receive_cash.amount,
            :voucher_number => receive_cash.voucher_number,
            :created_by => receive_cash.created_by,
            :deleted => false,
            :description => receive_cash.description,
            :corresponding_account_id => receive_cash.from_account_id )

          #build relationship between invoice and ledgers
          ledgers << from_ledger_entry
          ledgers << to_ledger_entry
          #save the associated ledgers
          from_ledger_entry.save
          to_ledger_entry.save
        end
        save_result = true
      end
    end
    save_result
  end

end
