class Gstr3bSection32

  def initialize(invoices)
    @invoices = invoices
    @unregistered_invoices = Array.new
    @unregistered_inv_amt = 0
    @unregistered_igst_tax_amt = 0
    categorize_invoices
  end

  def unregistered_invoices
    @unregistered_invoices
  end

  def unregistered_inv_amt
    @unregistered_inv_amt
  end

  def composition_inv_amt
  end

  def uin_inv_amt
  end

  def unregistered_igst_tax_amt
    @unregistered_igst_tax_amt
  end

  def composition_tax_amt
  end

  def uin_tax_amt
  end

  private

    def categorize_invoices
      @unregistered_invoices = Array.new
      @composition_invoices = Array.new
      @uin_invoices = Array.new
      @invoices.each do |invoice|

        if invoice.customer_GSTIN.blank? && invoice.contains_igst_tax_line_item?
          Rails.logger.debug "======Invoice details #{invoice.id} #{invoice.invoice_number} #{invoice.place_of_supply_state} #{invoice.sub_total}=========="
          @unregistered_invoices << invoice
          @unregistered_inv_amt += invoice.sub_total
          @unregistered_igst_tax_amt += invoice.igst_tax_amt
        end
      end
    end

end
