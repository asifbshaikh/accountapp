class Gstr3bSection3
  
  def initialize(invoices, reverse_purchases, reverse_expenses)
    @invoices = invoices
    @reverse_purchases = reverse_purchases
    @reverse_expenses = reverse_expenses
    calc_invoice_gst_amts
    calc_reverse_purchase_gst_amts
    calc_reverse_expense_gst_amts
  end

  def non_exempt_invoices
    @non_exempt_invoices ||= filter_nonexempt_invoices
  end

  def section32
    @section32 ||= Gstr3bSection32.new(non_exempt_invoices)
  end

  def outward_taxable_amount
    @outward_taxable_amt ||= calc_invoice_taxable_amt
  end

  def outward_igst_tax_amt
    @outward_igst_tax_amt
  end

  def outward_cgst_tax_amt
    @outward_cgst_tax_amt
  end

  def outward_sgst_tax_amt
    @outward_sgst_tax_amt
  end

  def outward_cess_amt
    0
  end

  def outward_zero_gst_taxable_amt
    @outward_zero_gst_taxable_amt ||= calc_zero_gst_taxable_amt
  end

  def outward_zero_igst_tax_amt
    @outward_zero_igst_tax_amt = 0
  end

  def outward_zero_cgst_tax_amt
    @outward_zero_cgst_tax_amt = 0
  end

  def outward_zero_sgst_tax_amt
    @outward_zero_sgst_tax_amt = 0
  end

  def outward_zero_cess_amt
    0
  end

  def outward_nil_gst_taxable_amt
    @outward_nil_gst_taxable_amt ||= calc_nil_gst_taxable_amt
  end

  def outward_nil_igst_tax_amt
    @outward_nil_igst_tax_amt = 0
  end

  def outward_nil_cgst_tax_amt
    @outward_nil_cgst_tax_amt = 0
  end

  def outward_nil_sgst_tax_amt
    @outward_nil_sgst_tax_amt = 0
  end

  def outward_nil_cess_amt
    0
  end

  def inward_reverse_taxable_amt
    @inward_reverse_taxable_amt ||= calc_reverse_purchase_taxable_amt
  end

  def inward_reverse_igst_tax_amt
    @inward_reverse_igst_tax_amt + @inward_reverse_exp_igst_tax_amt
  end

  def inward_reverse_cgst_tax_amt
    @inward_reverse_cgst_tax_amt + @inward_reverse_exp_cgst_tax_amt
  end

  def inward_reverse_sgst_tax_amt
    @inward_reverse_sgst_tax_amt + @inward_reverse_exp_sgst_tax_amt
  end

  def inward_reverse_cess_amt
    0
  end

  #section 3.2
  def unregistered_supplies_amt

  end

  private

    def calc_invoice_taxable_amt
      taxable_amt = 0
      @invoices.each do |invoice|
        if invoice.tax_inclusive?
          taxable_amt += (invoice.total_amount - invoice.tax)
        else
          taxable_amt += invoice.sub_total
        end
      end
      taxable_amt
    end

    def calc_invoice_gst_amts
      igst_tax_amt = 0
      cgst_tax_amt = 0
      sgst_tax_amt = 0
      @invoices.each do |invoice|
        invoice.tax_line_items.each do |line_item|
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
      @outward_igst_tax_amt, @outward_cgst_tax_amt, @outward_sgst_tax_amt = igst_tax_amt, cgst_tax_amt, sgst_tax_amt
    end

    def calc_zero_gst_taxable_amt
      taxable_amt = 0
      @invoices.each do |invoice|
        if invoice.contains_zero_gst_tax_line_item?
          taxable_amt += invoice.zero_item_taxable_value
        end
      end
      taxable_amt
    end

    def calc_nil_gst_taxable_amt
      taxable_amt = 0
      @invoices.each do |invoice|
        if invoice.contains_nil_gst_tax_line_item?
          taxable_amt += invoice.nil_item_taxable_value
        end
      end
      taxable_amt
    end

    def filter_nonexempt_invoices
      non_exempt_invoices = Array.new
      @invoices.each do |invoice|
        if invoice.place_of_supply.present?
          non_exempt_invoices  << invoice
        end
      end
      non_exempt_invoices
    end

    def calc_reverse_purchase_taxable_amt
      taxable_amt = 0
      @reverse_purchases.each do |purchase|
        taxable_amt += purchase.sub_total
      end
      taxable_amt
    end

    def calc_reverse_purchase_gst_amts
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

    def calc_reverse_expense_gst_amts
      igst_tax_amt = 0
      cgst_tax_amt = 0
      sgst_tax_amt = 0
      @reverse_expenses.each do |expense|
        expense.tax_line_items.each do |line_item|
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
      @inward_reverse_exp_igst_tax_amt, @inward_reverse_exp_cgst_tax_amt, @inward_reverse_exp_sgst_tax_amt = igst_tax_amt, cgst_tax_amt, sgst_tax_amt
    end


end