module DutiesAndTaxesHelper

  VOUCHER_TYPES = {'Invoice' => "invoices", 'Purchase' => 'purchases',
    'InvoiceReturn' => 'invoice_returns','PurchaseReturn' => 'purchase_returns', 'Expense' => 'expenses',
    'Journal' => 'journals', 'PaymentVoucher' => 'payment_vouchers', 'ReceiptVoucher' => 'receipt_vouchers',
    'TransferCash' => 'transfer_cashes', 'IncomeVoucher' => 'income_vouchers', 'Withdrawal' => 'withdrawals',
    'Deposit' => 'deposits'
  }

  def voucher_link(ledger)
    controller_name = VOUCHER_TYPES[ledger.voucher_type]
    if controller_name.present?
      link_to ledger.voucher_number, controller: controller_name, action: "show", id: ledger.voucher.id
    else
      ledger.voucher_number
    end  
  end

  def account_vat_tin(account)
    account.get_party.vat_tin unless account.get_party.blank?
  end

  def sales_vat_amount(ledger)
    vat_amount = ledger.credit
    if vat_amount ==0
      vat_amount = -1 * ledger.debit
    end
    vat_amount
  end

  def purchase_vat_amount(ledger)
    vat_amount = ledger.debit
    if vat_amount ==0
      vat_amount = -1 * ledger.credit
    end
    vat_amount
  end

  def other_vat_amount(ledger, account_name)
    vat_amount = 0

    if account_name.include? "sales"
      if ledger.debit > 0
        vat_amount = -1 * ledger.debit
      else
        vat_amount = ledger.credit
      end
    else
      if ledger.debit > 0
        vat_amount = ledger.debit
      else
        vat_amount = -1 *ledger.credit
      end
    end
    vat_amount
  end

end
