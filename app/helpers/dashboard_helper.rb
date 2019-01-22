module DashboardHelper

  LABELS = {"created" => "label label-green", "updated" => "label label-blue", "deleted" => "label label-red", "restored" => "label label-grey"}
  INVOICE_COUNTS = {0=>"danger", 1=>"inverse", 2=>"success", 3 =>"info"}
  INVOICE_COUNTS_COLORS = {0=>"'#FF5F5F'", 1=>"'#233445'", 2=>"'#3FCF7F'", 3 =>"'#5191D1'"}

  def label_class(action_code)
    LABELS[action_code]
  end

  def inv_count_class(status_id)
    INVOICE_COUNTS[status_id]
  end

  def inv_count_colors_array(keys)
    colors = Array.new()
    keys.each{|k| colors.push(INVOICE_COUNTS_COLORS[k])}
    colors.join(",")
  end

  def notification
    @notifications.blank? ? 'You do not have any notifications today!' : ''
  end

  def user_display_name(logged_user)
    logged_user.first_name
  end

  def last_login_time
    "Your last login was on #{session[:last_login_at]}." unless session[:last_login_at].blank?
  end

  #displays the take a tour link if the user is onboarded within 15 days
  def display_tour
    time_since_onboarding = (Time.zone.now.to_date - @current_user.created_at.to_date ).to_i
    if time_since_onboarding <= 15
      link_to raw('<i class="icon-play-sign"></i> Take A Tour'), "#", :class => "btn btn-success", :id =>"btn_tour"
    end
  end
  def setup_guide
    if @current_user.owner?
      time_since_onboarding = (Time.zone.now.to_date - @current_user.created_at.to_date ).to_i
      if time_since_onboarding <= 15
        link_to raw('<i class="icon-cog"></i> Setup Guide'), "http://www.profitbooks.net/setup-profitbooks?utm_source=profitbooksDashboard&utm_medium=Dashboardbtn&utm_campaign=Internal", :class => "btn btn-info", :target=>"_blank"
      end
    end
  end

  def monthly_income
    format_currency @monthly_income.sum
  end

  def monthly_expense
    format_currency @monthly_expense.sum
  end

  def last_6month_income
    format_currency @last_6month_income.sum
  end

  def last_6month_expense
    format_currency @last_6month_expenses.sum
  end

  def yearly_income
    format_currency @yearly_income.sum
  end

  def yearly_expense
    format_currency @yearly_expenses.sum
  end

  def daily_intervals
    date= Time.zone.now.beginning_of_month.to_date
    date_content =""
    while date <= Time.zone.now.to_date  do
      date_content << content_tag(:li, date.to_formatted_s(:short))
      date = date+1.days
    end
    raw date_content
  end

  def graph_product_names
    product_names =""
    @product_list.each do |product|
      product_names << content_tag(:li, product[0])
    end
    raw product_names
  end

  def graph_reorder_product_names
    product_names =""
    @reorder_products.each do |product|
      product_names << content_tag(:li, product.name)
    end
    raw product_names
  end

  def product_names
    product_names =[]
    @product_list.each do |product|
      product_names << product[0]
    end
    product_names
  end

  def product_quantities
    quantities = []
    @product_list.each do |product|
      quantities << product[1]
    end
    quantities
  end

  def reorder_product_quantities
    quantities = []
    @reorder_products.each do |product|
      quantities << "[#{product.reorder_level.to_i},#{product.sum_quantity.to_i}]"
    end
    quantities
  end

  def display_receivables(rec, mode)
    if rec.present?
      content =""
      rec.each do |r|
        amount = r.outstanding
        content += content_tag(:tr) do
          content_tag(:td, link_to(r.customer_name, invoice_path(r.id), :title=>r.invoice_number)) +
          content_tag(:td, format_amt_with_currency(r.currency, amount.abs), :align => 'right') +
          if (mode == "day")
            content_tag(:td, distance_of_time_in_words(r.due_date, Time.now.to_date))
          end
        end
      end
      content.html_safe
    else
      content_tag :tr do
        content_tag :td, :colspan=>"2" do
          content_tag :div, :class =>"alert alert-info" do
            content_tag :h6 do
              "<i class= 'icon-info-sign icon-large') <strong>You haven't created any invoices yet!</strong>".html_safe
            end
          end
        end
      end
    end
  end

  def display_expenses(exp, mode)
    if !exp.blank?
      content =""
      exp.each do |e|
        amount = e.foreign_currency? ? e.outstanding*e.exchange_rate : e.outstanding
        content += content_tag(:tr) do
          content_tag(:td, link_to(e.customer_name, purchase_path(e.id))) +
          content_tag(:td, format_currency(amount.abs), :align => 'right') +
          if (mode == "day")
            content_tag(:td, distance_of_time_in_words(e.due_date, Time.now.to_date))
          end
        end
      end
      content.html_safe
    else
      content_tag :tr do
        content_tag :td, :colspan=>"2" do
          content_tag :div, :class =>"alert alert-info" do
            content_tag :h6 do
              "<i class= 'icon-info-sign icon-large') <strong>You haven't made any expenses yet!</strong>".html_safe
            end
          end
        end
      end
    end
  end

  def display_cash_or_bank_accounts(accounts)
    if !accounts.blank?
      content =""
      counter = 0
      accounts.collect do |acc|
        if counter == 5
          break
        end
        total_amount = acc.balance_on_date(Time.zone.now.to_date)
        content += content_tag(:tr) do
          concat content_tag(:td, link_to(acc.name, {:controller => :account_books_and_registers, :action => :ledger, :account_id => acc.id})) +
          content_tag(:td, format_amount(total_amount), :align => 'right')
        end
        counter += 1
      end
      content.html_safe
    else
      content_tag :tr do
        content_tag :td, :colspan=>"2" do
          content_tag :div, :class =>"alert alert-info" do
            content_tag :h6 do
              "<i class= 'icon-info-sign icon-large') <strong>You haven't created any cash or bank accounts yet!</strong>".html_safe
            end
          end
        end
      end
    end
  end

end
