class FinalAccount < ActiveRecord::Base
  def self.total_balance(accounts)
    total = 0
    for acc in accounts
      total += acc.closing_balance
    end
    total
  end
end
