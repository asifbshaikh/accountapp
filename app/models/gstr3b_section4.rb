class Gstr3bSection4
  
  def initialize(purchases, reverse_purchases, expenses, reverse_expenses)
    @purchases = purchases
    @reverse_purchases = reverse_purchases
    @expenses = expenses
    @reverse_expenses = reverse_expenses
    calc_purchase_tax_amounts
    calc_expense_tax_amounts
    calc_reverse_purchase_tax_amounts
  end


  def total_igst_tax_amt
    igst_tax_amt + inward_reverse_igst_tax_amt
  end

  def total_cgst_tax_amt
    cgst_tax_amt + inward_reverse_cgst_tax_amt
  end

  def total_sgst_tax_amt
    sgst_tax_amt + inward_reverse_sgst_tax_amt
  end

  def total_cess_amt
    cess_amt + inward_reverse_cess_amt
  end


  def igst_tax_amt
    @pur_igst_tax_amt + @exp_igst_tax_amt
  end

  def cgst_tax_amt
    @pur_cgst_tax_amt + @exp_cgst_tax_amt
  end

  def sgst_tax_amt
    @pur_sgst_tax_amt + @exp_sgst_tax_amt
  end

  def cess_amt
    @cess_amt = 0
  end


  def net_igst_tax_amt
    total_igst_tax_amt 
  end

  def net_cgst_tax_amt
    total_cgst_tax_amt
  end

  def net_sgst_tax_amt
    total_sgst_tax_amt
  end

  def net_cess_amt
    total_cess_amt
  end

  def inward_reverse_taxable_amt
    @inward_reverse_taxable_amt ||= calc_reverse_purchase_taxable_amt
  end

  def inward_reverse_igst_tax_amt
    @inward_reverse_igst_tax_amt
  end

  def inward_reverse_cgst_tax_amt
    @inward_reverse_cgst_tax_amt
  end

  def inward_reverse_sgst_tax_amt
    @inward_reverse_sgst_tax_amt
  end

  def inward_reverse_cess_amt
    0
  end


  private

    def calc_purchase_tax_amounts
      #Rails.logger.debug "========inside section 4 calc_tax_amounts========="
      igst_tax_amount = 0
      cgst_tax_amount = 0
      sgst_tax_amount = 0

      @purchases.each do |purchase|
        #Rails.logger.debug "=============Purchase is #{purchase.id} #{purchase.purchase_number} #{purchase.igst_tax_amt}========="
        igst_tax_amount += purchase.igst_tax_amt
        cgst_tax_amount += purchase.cgst_tax_amt
        sgst_tax_amount += purchase.sgst_tax_amt
      end

      @pur_igst_tax_amt, @pur_cgst_tax_amt, @pur_sgst_tax_amt = igst_tax_amount, cgst_tax_amount, sgst_tax_amount
    end

    def calc_expense_tax_amounts
      igst_tax_amt = 0
      cgst_tax_amt = 0
      sgst_tax_amt = 0

      @expenses.each do |expense|
        #Rails.logger.debug "=============Expense is #{expense.id} #{expense.voucher_number} #{expense.igst_tax_amt}========="
        igst_tax_amt += expense.igst_tax_amt
        cgst_tax_amt += expense.cgst_tax_amt
        sgst_tax_amt += expense.sgst_tax_amt
      end

      @exp_igst_tax_amt, @exp_cgst_tax_amt, @exp_sgst_tax_amt = igst_tax_amt, cgst_tax_amt, sgst_tax_amt
    end

    def calc_reverse_purchase_tax_amounts
      igst_tax_amt = 0
      cgst_tax_amt = 0
      sgst_tax_amt = 0
      @reverse_purchases.each do |purchase|
        purchase.tax_line_items.each do |line_item|
          act_name = line_item.account.name
          if act_name.include? "IGST"
            igst_tax_amt += line_item.amount
          elsif act_name.include? "CGST"
            cgst_tax_amt += line_item.amount
          elsif act_name.include? "SGST"
            sgst_tax_amt += line_item.amount
          end  
        end  
      end
      @inward_reverse_igst_tax_amt, @inward_reverse_cgst_tax_amt, @inward_reverse_sgst_tax_amt = igst_tax_amt, cgst_tax_amt, sgst_tax_amt
    end


end