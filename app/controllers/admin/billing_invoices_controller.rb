class Admin::BillingInvoicesController < ApplicationController
	layout "admin"
	skip_before_filter  :company_from_subdomain, :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
	before_filter :authorize_super_user
       skip_after_filter :intercom_rails_auto_include
	def index
		@menu = "Billing"
		@page_name = "Listing invoices"
		@billing_invoices = BillingInvoice.order("created_at ASC")

    respond_to do |format|
      format.html #index.html.erb
      format.html # new.html.erb
      format.xls
      format.xml  { render :xml => @billing_invoices }
      format.json { render :json => BillingInvoicesDatatable.new(view_context)}
    end
	end
  def new
  	@menu = "Billing"
  	@page_name = "New invoice"
     @companies = Company.all
     @super_users = SuperUser.where(:active => true)
  	# @companies=[]
  	# Company.all.each do |company|
  	# 	@companies<<company.name 
  	# end
  end

  def create
    validity =  params[:next_renewal_date].to_date - params[:renewal_date].to_date unless params[:next_renewal_date].blank?
    validity = (validity / 30) unless validity.blank?
  	renewat_date = params[:renewal_date].to_date 
    next_renewal_date = params[:next_renewal_date].to_date unless params[:next_renewal_date].blank?
    plan_name = params[:plan_name]
    plan_amount = params[:plan_amount].to_i unless params[:plan_amount].blank?
    company = Company.find params[:company_id] unless params[:company_id].blank?

    coupon_code = params[:coupon_code]
    coupon_amount = params[:coupon_amount].to_i

    amount = 0
    # creating plan line item
    plan = Plan.find_by_name(plan_name)
    if !plan.blank? && !plan_amount.blank?
      plan_line_item = BillingLineItem.new(
        :company_id => company.id,
        :line_item => plan.display_name,
        :billing_type => "plan",
        :amount => plan_amount,
        :validity => validity
        )
      amount = amount + plan_amount
    end

    if !coupon_code.blank? && !coupon_amount.blank?
      coupon_line_item = BillingLineItem.new(
        :company_id => company.id,
        :line_item => coupon_code,
        :billing_type => 'coupon',
        :amount => coupon_amount
      )
      amount -= coupon_amount
    end

    if !company.blank?    
    @billing_invoice = BillingInvoice.new(
      :company_id => company.id,
      :invoice_number => generate_invoice_number,
      :invoice_date => Time.zone.now.to_date,
      :amount =>  amount,
      :created_by => company.users[0].id,
      :received_by => params[:received_by],
      :closed_by => params[:closed_by]
    )
  


    @billing_invoice.billing_line_items<<plan_line_item unless plan_line_item.blank?
    @billing_invoice.billing_line_items<<coupon_line_item unless coupon_line_item.blank?
    @billing_invoice.payment_detail = fetch_payment_details(params[:payment_mode])
    @billing_invoice.payment_detail.amount = amount


    if @billing_invoice.valid?
      @billing_invoice.save
      company.subscription.update_attributes(:status=>"Paid")
      @billing_invoice.mark_paid
      @billing_invoice.billing_line_items.each do |line_item|
        if line_item.billing_type == "plan"
          plan = Plan.find_by_display_name(line_item.line_item)
          company.subscription.upgrade_plan(plan.name, @billing_invoice.amount, validity)
        elsif line_item.billing_type == "user_pack"
          company.subscription.add_user_pack(line_item.line_item)
        elsif line_item.billing_type == "coupon"
          company.subscription.apply_discount_coupon(line_item.line_item, company.id, company.users[0].id)
        end  
      end

      # sending invoice as email 
      template = File.read("#{Rails.root}/app/views/admin/billing_invoices/show.pdf.prawn")
      pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')
      invoice = @billing_invoice
      pdf.instance_eval do
        @company = company
        @billing_invoice = invoice
        eval(template) 
      end
      attachment = pdf.render
      Email.send_billing_invoice(attachment, @billing_invoice, company, company.users[0]).deliver
      if company.lead_company.blank?
        CustomerRelationship.create_customer_relationships_for_paid(company.id)
      else
        LeadActivity.create_lead_activities_for_paid(company)
      end
      flash[:success] = "Payment was done successfully."
      redirect_to "/admin/billing_invoices/show?id=#{@billing_invoice.id}"
    else
      flash[:error] = 'Something wrong'
      redirect_to :back
    end
  else
    flash[:error] = 'Something wrong'
      redirect_to :back
    end
  end

  def show
  	@menu = "Billing"
  	@page_name = "Invoice details"
    @billing_invoice = BillingInvoice.find(params[:id])
    @company = @billing_invoice.company
    @user = @company.users.first
  end

  def get_company
  	@company = Company.find(params[:company_name])
  end

  def fetch_payment_details(transaction_type)
    if transaction_type == 'cheque'
      payment = ChequePayment.new(
        :account_number => params[:cheque_number],
        :bank_name => params[:bank_name],
        :payment_date => params[:cheque_transaction_date]
      )
    elsif transaction_type == 'ibank'
      payment = InternetBankingPayment.new(
        :transaction_reference => params[:transaction_reference],
        :payment_date => Time.zone.now.to_date
        )
    else
      payment = CashPayment.new(
        :payment_date => Time.zone.now.to_date
        )
    end
    payment
  end 

  private
  def generate_invoice_number
    #create the unique reference for transaction
    @sequence = BillingInvoiceSequence.create
    @sequence = Date.today.to_s(:number)+ pad_sequence(@sequence.id) 
  end

  def pad_sequence(seq)
    if seq < 10
      "00"+seq.to_s
    elsif seq >= 10 and seq < 100
      "0"+ seq.to_s
    else
      seq.to_s
    end
  end
end
