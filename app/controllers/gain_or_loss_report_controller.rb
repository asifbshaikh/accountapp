class GainOrLossReportController < ApplicationController
  def index
    @page_name = "Gain or Loss Report"
    @account = Account.find_by_company_id_and_name(@company.id, "Gain or loss on fluctuation in foreign currency")
    unless @account.blank?
      @ledgers = Ledger.get_gl_record(params, @financial_year, @current_user, @account)
    end
     prawnto :filename => "gain_or_loss_report.pdf"
  end

  def currency_wise
  end

  def customer_wise
  end

end
