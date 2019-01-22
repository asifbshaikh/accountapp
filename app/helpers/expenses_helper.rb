module ExpensesHelper
  EXPENSE_STATUS_BADGES = { Paid: "bg-primary", Unpaid: "bg-warning"}.with_indifferent_access

  def expense_tds_amount
    raw(number_with_precision @expense.deducted_tds, :precision=>2)
  end
	def expense_sub_total
		raw(number_with_precision @expense.sub_total, :precision=>2 )
	end
	def total_tax_amount
   amt=0
   @expense.tax_line_items.each do |line_item|
       tax_account = line_item.account
       next if (tax_account.accountable_type=='DutiesAndTaxesAccounts' && tax_account.accountable.calculation_method==4 && tax_account.accountable.split_tax == 0)
       amt+= line_item.amount
    end
    
		raw(number_with_precision amt, :precision=>2)
	end

  def expense_paid_amount
    raw(number_with_precision @expense.paid_amount, :precision=>2)
  end

  def expense_outstanding
    number_with_precision @expense.outstanding, :precision=>2
  end

  def expense_status_badge(status)
    ExpensesHelper::EXPENSE_STATUS_BADGES[status]
  end

end
