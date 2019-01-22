class Gstr3bReport < ActiveRecord::Base

  belongs_to :company

  STATUS = {draft: 0, populate: 1, prepared: 2, final: 3}
  STATUS_NAMES = %w{draft populated prepared final}


  def status_name
    status ? STATUS_NAMES[status] : STATUS_NAMES[0]
  end

  def month_name
    Date::MONTHNAMES[self.month]
  end

  def invoices
    company.invoices.includes(:tax_line_items).includes(:account).includes(:customer).where("invoice_date >= ? and invoice_date <= ?", start_date, end_date).order(:place_of_supply)
  end

  def purchases
    company.purchases.includes(:tax_line_items).includes(:account).where(gst_purchase: true, reverse_charge: false).where("record_date >= ? and record_date <= ?", start_date, end_date)
  end

  def reverse_purchases
    company.purchases.where(gst_purchase: true, reverse_charge: true).where("record_date >= ? and record_date <= ?", start_date, end_date)
  end

  def expenses
    company.expenses.where(gst_expense: true, reverse_charge: false).where("expense_date >= ? and expense_date <= ?", start_date, end_date)
  end

  def reverse_expenses
    company.expenses.where(gst_expense: true, reverse_charge: true).where("expense_date >= ? and expense_date <= ?", start_date, end_date)
  end

  def generate_section3
    @gstr3b_section3 = Gstr3bSection3.new(invoices, reverse_purchases, reverse_expenses)
  end

  def generate_section4
    @gstr3b_section4 = Gstr3bSection4.new(purchases, reverse_purchases, expenses, reverse_expenses)
  end

  def generate_section5
    @gstr3b_section5 = Gstr3bSection5.new(purchases, expenses)
  end

  def generate_section61
    @gstr3b_section6 = Gstr3bSection61.new(@gstr3b_section3, @gstr3b_section4)
  end
  private

    def report_date
      @report_date ||= Time.zone.now.to_date.change(:month => self.month)
    end

    def start_date
      report_date.beginning_of_month
    end

    def end_date
      report_date.end_of_month
    end

end
