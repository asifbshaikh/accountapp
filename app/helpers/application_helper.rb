module ApplicationHelper
  # This method check the current controller name against the list of controllers in each menu
    # and when matched it sets the result = current which is the CSS class for highlighting the
  # current menu
  def tab_selection(name)
    result = nil
    if name =='dashboard'
      result = ['dashboard'].include? @current_controller
    elsif name == 'income'
      result = ['income','receipt_vouchers','invoices','estimates','income_vouchers'].include? @current_controller
    elsif name == 'expenses'
      result = ['expenses','payments','purchases','purchase_orders','payment_vouchers'].include? @current_controller
    elsif name == 'banking'
      result = ['withdrawals','deposits','transfer_cashes','bank_reconciliation'].include? @current_controller
    elsif name == 'journal'
      result = ['journals','credit_notes','debit_notes','saccountings'].include? @current_controller
    elsif name == 'inventory'
      result = ['inventory','products','warehouses','stock_issue_vouchers','stock_receipt_vouchers'].include? @current_controller
    elsif name == 'reports'
          result = ['payment_advice','employee_breakup', 'vertical_balance_sheet','horizontal_balance_sheet','vertical_profit_and_loss','horizontal_profit_and_loss','trial_balance','bank_book',
                    'cash_book','credit_note_register','debit_note_register','journal_register','account_books_and_registers','bills_payable','bills_receivable',
                    'purchase_register','sales_register','sundry_creditor','ledgers','day_book','stock_wastage_register','low_stock','sales_order_reports'].include? @current_controller
    elsif name == 'settings'
          result = ['companies','users'].include? @current_controller
    elsif name == 'selfservice'
      result = ['assets','employee_goals','leaves','leave_requests','leave_approval'].include? @current_controller
    elsif name == 'timesheets'
      result = ['timesheets','tasks'].include? @current_controller
    elsif name == 'forms'
      result = ['leave_requests'].include? @current_controller
    elsif name == 'organisation'
      result = ['organisation_announcements','holidays','policy_documents'].include? @current_controller
   elsif name == 'administration'
      result = ['master_objectives','employee_goals','users','salary_structures','departments','designations','process_payrolls'].include? @current_controller
    elsif name == 'login'
      result = ['login'].include? @current_controller
    elsif name == 'adminlogin'
      result = ['admin/login'].include? @current_controller
    elsif name == 'payroll'
      result=['payroll_details', 'users', 'leave_requests', 'company_assets', 'payheads', 'attendances'].include? @current_controller
    elsif name=='accounting'
      result=['accounts', 'account_heads', 'duties_and_taxes', 'journals', 'debit_notes', 'credit_notes', 'saccountings', 'auditors'].include? @current_controller
    end
    if result
      result = "active"
    end
    result
  end

#for default_title in title bar
def screen_title(name)
  title = nil
   if name == 'expenses'
     title = "Record Expenses"
   elsif name =='purchase'
       title = "Record Purchases"
   elsif name == 'payment_vouchers'
      title = "Make Payments"
   elsif ['withdrawals','deposits','transfer_cashes'].include?(name)
     title ='Banking'
   elsif name == 'accounts'
      title = "Chart of Accounts"
   elsif name == 'duties_and_taxes'
      title ="Taxation"
   elsif name =='journals'
      title = "Journal Entry"
   elsif name == 'saccountings'
      title = "Simple Accounting Entry"
   elsif name == 'products'
      title = "Products/Services"
   elsif ['stock_issue_vouchers','stock_receipt_vouchers','stock_wastage_vouchers','stock_transfer_vouchers'].include?(name)
       title = "Manage Stock"
   elsif name =='payroll_details'
      title ="Manage Payroll"
   elsif name == 'users'
     title = "Employees"
   elsif name =='company_assets'
     title ="Manage Assets"
   elsif name == 'tasks'
     title = "Manage Tasks"
   elsif name == 'messages'
     title = "Send or receive Messages"
   elsif ['account_books_and_registers','horizontal_balance_sheet','horizontal_profit_and_loss','trial_balance','day_book','cash_book',
                    'bank_book','journal_register','credit_note_register','debit_note_register','custom_fields','sales_register','bills_receivable',
                    'bills_payable','customer_statements','purchase_register','sundry_creditor','product_wise_stock','warehouse_wise_stock','low_stock',
                    'stock_wastage_register','payment_advice','employee_breakup','workstreams','gain_or_loss_report', 'sales_order_reports'].include?(name)
     title = 'Report'
   elsif name == 'account_heads'
    title = "Account Groups"
   elsif name == 'myprofile'
    title = "My Profile"
   elsif name == "pbservices"
    title = "BookKeeping & Legal"
   elsif name == "reimbursement_notes"
     title = "Reimbursement Vouchers"
   elsif name == "reimbursement_vouchers"
     title = "Reimubursement Receipts"
   else
      title = name.humanize
   end
   title
  end

  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}, {:class => css_class}
  end

  # showing taxes by comma separated in case double tax
  def applied_taxes(line_item)
    names=""
    line_item.tax_accounts.each do |account|
      names+= ", " if line_item.tax_accounts.last.equal?(account) && !line_item.tax_accounts.first.equal?(account)
      names+= account.name.chomp('on sales')
    end
    names
  end

  def applied_taxes_on_purchase(line_item)
    names=""
    line_item.tax_accounts.each do |account|
      names+= ", " if  !line_item.tax_accounts.first.equal?(account)
      names+= account.name.chomp('on purchase')
    end
    names
  end

  def applied_taxes_on_expense(line_item)
    names=""
    line_item.tax_accounts.each do |account|
      names+= ", " if  !line_item.tax_accounts.first.equal?(account)
      names+= account.name.chomp('on purchase')
    end
    names
  end

  def format_amount(amount)
    if amount.blank?
      amount=0
    end
    number_to_currency(amount, :unit => "", :precision=> 2)
  end

  # for currency display
  def format_currency(amt)
    unit = @company.country.currency_code
    number_to_currency(amt, :unit => unit+" ", :precision=> 2)
  end

  def format_amt_with_currency(currency_code, amt)
    if currency_code.blank?
      unit = @company.country.currency_code
    else
      unit = currency_code
    end
    number_to_currency(amt, :unit => unit +" ", :precision=> 2)
  end

  def format_currency_with_suffix(amount)
    suffix = " Dr"
    suffix = " Cr" if amount < 0
    format_currency(amount) + suffix
  end

#-------------------------------to convert total amount in words.-------------------------------------------
   
  def total_to_words(amount)
     numbers_to_name = {10000000 => "Crore",100000 => "Lakh",1000 => "Thousand",100 => "Hundred",90 => "Ninety",80 => "Eighty",70 => "Seventy",60 => "Sixty",50 => "Fifty",
      40 => "Forty", 30 => "Thirty",20 => "Twenty",19=>"Nineteen",18=>"Eighteen",17=>"Seventeen",16=>"Sixteen",
      15=>"Fifteen", 14=>"Fourteen",13=>"Thirteen",12=>"Twelve",11 => "Eleven",10 => "Ten",9 => "Nine",
      8 => "Eight",7 => "Seven",6 => "Six",5 => "Five",4 => "Four",3 => "Three",2 => "Two",1 => "One"
    }
      str = ""
     numbers_to_name.each do |num, name|
      if amount == 0
        return str
     elsif amount.to_s.length == 1 && amount/num > 0
        return str + " #{name}"
    elsif amount < 100 && amount/num > 0
        return str + " #{name}" if amount%num == 0
        return str + " #{name}"+ total_to_words(amount%num)
    elsif amount/num > 0
          return str + total_to_words(amount/num) + " #{name} " + total_to_words(amount%num)
      end
    end
  end

  def amount_in_words(amount)
   integer = amount.to_i
    decimal = (amount - amount.to_i) * 100
  if decimal != 0
    return "#{total_to_words(integer)} Rupees and #{total_to_words(decimal.floor)} Paise Only."
  else
   return "#{total_to_words(integer)} Rupees Only."
  end
end

#--------------------------------------------------------------------------------------------------------------

  def set_timezone
    if !@company.blank?  && !@company.country.blank?
      Time.zone = @company.timezone unless @company.timezone.blank?
    end
  end

#method to get company address
  def address_info
    if @company.address.blank?
      return ""
    end
    address = ''
    address = @company.address.address_line1 + ", <br/>"  unless @company.address.address_line1.blank?
    # address += @company.address.address_line2 + ", <br/>" unless @company.address.address_line2.blank?
    # address += @company.address.city + " , " unless @company.address.city.blank?
    # address += @company.address.state + ", <br/>" unless @company.address.state.blank?
    # address += @company.address.country + " - " unless @company.address.country.blank?
    # address += @company.address.postal_code + "<br/>" unless @company.address.postal_code.blank?
  end

  def link_to_pdf(params)
     link_to image_tag('pdf.gif', :class => 'icon'), url_for(:format => 'pdf',
      :start_date => params[:start_date], :end_date => params[:end_date], :month => params[:month],:name => params[:name], :customer_id=> params[:customer_id],
      :branch_id => params[:branch_id], :account_id => params[:account_id],:user_id => params[:user_id], :transaction_type=> params[:transaction_type], :product_id=> params[:product_id],
      :for_date => params[:for_date], :balance_sheet_date => params[:balance_sheet_date], :warehouse_id => params[:warehouse_id] ,:id => params[:id], :line_items => params[:line_items]), :class => "btn btn-white btn-lg", :target => "_blank", :title=>"Export to PDF"
  end

  def link_to_xls(params)
     link_to image_tag('excel_icon.gif', :class => 'icon'), url_for(:format => 'xls', :customer_id=> params[:customer_id], :product_id => params[:product_id], :line_items => params[:line_items],
      :start_date => params[:start_date], :end_date => params[:end_date], :branch_id => params[:branch_id],:month => params[:month],:name => params[:name], :transaction_type=> params[:transaction_type],
      :account_id => params[:account_id], :balance_sheet_date => params[:balance_sheet_date], :user_id => params[:user_id], :for_date => params[:for_date], :warehouse_id => params[:warehouse_id], :id => params[:id]), :class => "btn btn-white btn-lg",
      :target => "_blank", :title=>"Export to XLS"
  end

  # helper for options_from_collection_for_select_with_data where we can set data-attributes
  def options_from_collection_for_select_with_data_and_add_new(collection, value_method, text_method, selected = nil, data = {})
    content_tag(:option, "+ Add New", :value=>"create_new")+options_from_collection_for_select_with_data(collection, value_method, text_method, selected = nil, data = {})
  end

  def options_from_collection_for_select_with_add_new(collection, value_method, text_method, selected , data = {})
    content_tag(:option, "+ Add New", :value=>"create_new")+options_from_collection_for_select(collection, value_method, text_method, selected = selected)
  end

  def options_from_collection_for_select_with_data(collection, value_method, text_method, selected = nil, data = {})
      options = collection.map do |element|
        [element.send(text_method), element.send(value_method), data.map do |k, v|
          {"data-#{k}" => element.send(v)}
        end
        ].flatten
      end
      selected, disabled = extract_selected_and_disabled(selected)
      select_deselect = {}
      select_deselect[:selected] = extract_values_from_collection(collection, value_method, selected)
      select_deselect[:disabled] = extract_values_from_collection(collection, value_method, disabled)
      options_for_select(options, select_deselect)
  end

  def date_difference_in_months(start_date, end_date)
      (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month)
  end

  def breaking_word_wrap(text, *args)
     options = args.extract_options!
     unless args.blank?
       options[:line_width] = args[0] || 35
     end
     options.reverse_merge!(:line_width => 35)
     text = text.split(" ").collect do |word|
       word.length > options[:line_width] ? word.gsub(/(.{1,#{options[:line_width]}})/, "\\1 ") : word
     end * " "
     text.split("\n").collect do |line|
       line.length > options[:line_width] ? line.gsub(/(.{1,#{options[:line_width]}})(\s+|$)/, "\\1\n").strip : line
     end * "\n"
  end
  def summarize(body, length)
   return simple_format(truncate(body.gsub(/<\/?.*?>/,  ""), :length => length)).gsub(/<\/?.*?>/,  "")
  end

  def new_button(title, path)
    link_to image_tag('add.png', :class => 'icon') + title, path, :class => 'btn btn-special btn-green', :alt => title
  end

  def edit_button(title, path)
    link_to image_tag('black_ic_edit.png', :class => 'icon') + title, path, :class => 'btn btn-special btn-gray', :alt => title
  end

  def edit_button_white(title, path)
    link_to image_tag('white_ic_edit.png', :class => 'icon') + title, path, :class => 'btn btn-special btn-green', :alt => title
  end

  def list_button_black(title, path)
    link_to image_tag('black_ic_list.png', :class => 'icon') + title, path, :class => 'btn btn-special btn-gray'
    #list_button title, path, 'black'
  end

  def list_button_white(title, path)
    link_to image_tag('white_ic_list.png', :class => 'icon') + title, path, :class => 'btn btn-special btn-green'
    #list_button title, path, 'white'
  end

  def list_button(title, path, color)
    link_to image_tag("#{color}_ic_list.png", :class => 'icon') + title, path, :class => 'btn btn-special btn-gray'
  end

  def pdf_button(title, path)
    link_to image_tag('pdf.gif', :class => 'icon') + title, path, :class => "btn btn-special btn-gray", :target => "_blank"
  end

  def email_button(title, path)
    link_to image_tag('send.png', :class => 'icon') + title, path, :class => "btn btn-special btn-gray"
  end

  def payment_button(title, path)
    link_to image_tag('money.png', :class => 'icon') + title, path, :class => "btn btn-special btn-gray"
  end

  def copy_button(title, path)
    link_to raw('<i class="icon-copy"> </i> Copy into new'), path
    # link_to image_tag('copy-icon.gif', :class => 'icon') + title, path, :class => "btn btn-special btn-gray"
  end

  def convert_button(title, path)
    link_to image_tag('black_ic_sync.png', :class => 'icon') + title, path, :class => "btn btn-special btn-gray"
  end

  def show_button_white(title, path)
    link_to image_tag('white_ic_archive.png', :class => 'icon') + title, path, :class => "btn btn-special btn-green"
  end

  def show_button(title, path)
    link_to image_tag('black_ic_archive.png', :class => 'icon') + title, path, :class => "btn btn-special btn-gray"
  end

  def help_icon
    image_tag 'help.png', :width=>'16', :height=>'16', :alt=>'Help', :class =>'icon'
  end
end
