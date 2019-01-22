class Payment < ActiveRecord::Base

   belongs_to :account
   has_many :ledgers, :as => :voucher

   #validations
   validates :payment_date,:amount,:from_account_id, :paid_to_account_id, :payment_mode , :presence=> true
   validates_length_of :description , :maximum => 300
   validates :amount, :numericality => {:greater_than_or_equal_to => 0.01,
                                        :message => " should not be zero or negative ." }
   validate :from_account_id_and_paid_to_account_id_validation

   def from_account_id_and_paid_to_account_id_validation
      if self.from_account_id == self.paid_to_account_id
          errors.add_to_base("Both accounts should not be same")
      end
  end
  def save_with_ledgers
    save_result = false
    transaction do
      if save
        payment.each do |payment|
          from_ledger_entry = Ledger.create(:account_id => payment.from_account_id,
            :transaction_date => payment.payment_date,
            :debit => payment.amount,
            :voucher_number => payment.voucher_number,
            :created_by => payment.created_by,
            :deleted => false,
            :description => payment.description,
            :corresponding_account_id => payment.paid_to_account_id )

          to_ledger_entry = Ledger.create(:account_id => payment.paid_to_account_id,
            :transaction_date => payment.payment_date,
            :credit => payment.amount,
            :voucher_number => payment.voucher_number,
            :created_by => payment.created_by,
            :deleted => false,
            :description => payment.description,
            :corresponding_account_id => payment.from_account_id)

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
