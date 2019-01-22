require 'base64'
require 'cgi'
require 'openssl'
class BillingController < ApplicationController
  include UrlHelper
  skip_before_filter :check_if_allow
  skip_before_filter :company_active?

  protect_from_forgery :except => :paymentresponse
  def index
    @subscription = @company.subscription
    @upgradable_plans = Plan.upgradable_plans(@subscription.plan.price) #if @company.plan.trial_plan?
    @plan = @company.plan
    #@company = Company.find_by_subdomain(request.subdomain)

  end

  def upgrade
    user_pack = params[:additional_users]
    user_pack_amount = 0 #user_pack.to_i*45*12
    validity = params[:validity].to_i
    earning = params[:earning].to_f
    remaining_days = 0
    order_total = 0;
    plan_name = ''
    plan = Plan.find_by_name(params[:plan_name])
    coupon_name = nil
    coupon_amt = 0
    coupon_cd = params[:coupon_code]
    coupon = Coupon.find_by_coupon_code(params[:coupon_code])
    if !plan.blank?
      plan_name = plan.name
      if !user_pack.blank? && user_pack != "0"
        user_pack_amount = user_pack.to_i*45*validity
        user_pack_amount = user_pack_amount * 1.145
      end
      if plan_name=='PWYW'
        order_total = params[:plan_amount].to_f*12 unless params[:plan_amount].blank?
      else
        order_total = plan.annual_price(validity,coupon)
      end
    elsif !user_pack.blank? && user_pack != "0"
      remaining_days = @company.subscription.end_date.to_date - Time.zone.now.to_date
      unless remaining_days <= 0
        months = remaining_days / 30.0
        user_pack_amount = user_pack.to_i*45*months
        user_pack_amount = user_pack_amount * 1.145
      end
    end
      order_total = order_total + user_pack_amount
    
    if !coupon.blank? && coupon.can_use?(@company.id, order_total,validity)
      coupon_name = coupon.name
      coupon_amt = coupon.get_coupon_amount(order_total)
    end
    if order_total < coupon_amt
      order_total = order_total - coupon_amt
    end
    amount = 0
    @discount = coupon_amt

    if !plan_name.blank?
      plan = Plan.find_by_name plan_name
      if plan.name=="PWYW"
        final_plan_price = params[:plan_amount].to_f*12 unless params[:plan_amount].blank?
      else
        final_plan_price = plan.annual_price(validity,coupon)
      end
      plan_line_item = BillingLineItem.new(
        :company_id => @company.id,
        :line_item => plan.display_name,
        :billing_type => "plan",
        :amount => final_plan_price,
        :validity => validity
      )
      amount += final_plan_price
      if coupon_amt == 0
       amount = amount * 1.18
      end  
    end

   if !user_pack.blank? && user_pack != "0"
      user_pack_line_item = BillingLineItem.new(
        :company_id => @company.id,
        :line_item => user_pack + " Users",
        :billing_type => "user_pack",
        :amount => user_pack_amount.to_f,
        :validity => "#{plan_name.blank? ? (remaining_days / 30.0 ) : validity }".to_f
      )
      amount += user_pack_amount.to_i
    end
    # creating coupon line item
    if !coupon_name.blank? && !coupon_amt.blank?
      coupon_line_item = BillingLineItem.new(
        :company_id => @company.id,
        :line_item => coupon_cd,
        :billing_type => 'coupon',
        :amount => (coupon.coupon_type == "Referral") ? 0 : coupon_amt,
        :validity => ( coupon.coupon_type == "Referral") ? 1 : ' '
      )
          amount -= coupon_amt
          amount = amount * 1.18
    end
    @billing_invoice = BillingInvoice.new(
      :company_id => @company.id,
      :invoice_number => generate_invoice_number,
      :invoice_date => Time.zone.now.to_date,
      :amount => amount,
      :created_by => @current_user.id
    )
    @billing_invoice.billing_line_items << plan_line_item unless plan_line_item.nil?
    @billing_invoice.billing_line_items << user_pack_line_item unless user_pack_line_item.nil?
    @billing_invoice.billing_line_items << coupon_line_item unless coupon_line_item.nil?
    payment = CardPayment.new(:payment_date => Time.zone.now)
    @billing_invoice.payment_detail = payment
    @billing_invoice.payment_detail.amount = amount
    respond_to do |format|
      if @billing_invoice.valid?
          @billing_invoice.save
          format.html { redirect_to(:action => :show , :id=> @billing_invoice)}
          format.xml  { render :xml => @billing_invoice, :status => :created, :location => @billing_invoice }
      else
        @menu = 'Billing'
        @page_name = 'Details'
        @subscription = @company.subscription
        @upgradable_plans = Plan.upgradable_plans(@subscription.plan.price)
        @plan = @company.plan
        format.html { render :action =>  "index" }
      end
    end
  end

  def show
    @menu = 'Billing'
    @page_name = 'Billing Invoice'
    @billing_invoice = BillingInvoice.find(params[:id])
    @company = @company
    if Rails.env.production?
      @gateway = PaymentGateway.find_by_production(true)
    else
      @gateway = PaymentGateway.find_by_production(false)
    end
    orderAmount = @billing_invoice.amount
    @merchantTxnId = payment_transaction_reference
    data = @gateway.vanity_url+orderAmount.to_s+@merchantTxnId+"INR"
    @encryptedVal = OpenSSL::HMAC.hexdigest('sha1',@gateway.key, data)
    payment_transaction = PaymentTransaction.create(
      :company_id => @company.id,
      :transaction_reference => @merchantTxnId,
      :billing_invoice_id => @billing_invoice.id,
      :signature => @encryptedVal
    )
    @responseURL = url_for(:action=> :paymentresponse)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @billing_invoice }
    end

  end

  def paymentresponse
    company = @company
    @user = @company.users.first
    @payment_transaction = PaymentTransaction.find_by_company_id_and_transaction_reference(@company.id, params[:TxId])
    @payment_transaction.update_attributes(
      :issuer_ref_num => params[:issuerRefNo],
      :auth_ID_code => params[:authIdCode],
      :transaction_status => params[:TxStatus],
      :transaction_msg => params[:TxMsg],
      :gateway_transaction_num => params[:pgTxnNo],
      :gateway_transaction_status => params[:TxStatus],
      :gateway_transaction_ref => params[:TxRefNo]
    )
    @billing_invoice = @payment_transaction.billing_invoice
    success = false
    if "SUCCESS" == params[:TxStatus]
      @company.subscription.update_attributes(:status=>"Paid")
      @billing_invoice.mark_paid
      @billing_invoice.billing_line_items.each do |line_item|
        if line_item.billing_type == "plan"
          plan = Plan.find_by_display_name(line_item.line_item)
          @company.subscription.upgrade_plan(plan.name, @billing_invoice.amount, line_item.validity)
          @company.reload
          session[:plan] = @company.plan.name
        elsif line_item.billing_type == "user_pack"
          @company.subscription.add_user_pack(line_item.line_item)
        elsif line_item.billing_type == "coupon"
          @company.subscription.apply_discount_coupon(line_item.line_item, @company.id, @current_user.id)
          Pbreferral.convert_to_paid(@current_user, line_item.line_item, @company, @billing_invoice.amount)
        end
      end
      # sending invoice as email
      template = File.read("#{Rails.root.to_s}/app/views/admin/billing_invoices/show.pdf.prawn")
      pdf = Prawn::Document.new(:page_layout => :portrait, :page_size => 'A4')
      invoice = @billing_invoice
      pdf.instance_eval do
        @company = company
        @billing_invoice = invoice
        eval(template)
      end
      attachment = pdf.render
      Email.send_billing_invoice(attachment, @billing_invoice, @company, @current_user).deliver
      success = true
    end
    respond_to do |format|
      if success
        flash[:success] = "You have successfully upgraded/renewed your plan!"
      else
        flash[:error] = "There was an error processing your request. Please try after sometime."
      end
      Email.payment_info(@user, @company, @payment_transaction , @billing_invoice).deliver
      format.html { redirect_to(:action => :index)}
    end
  end

  def apply_coupon
    @coupon = Coupon.find_by_coupon_code(params[:coupon_code])
    @order_total = params[:order_total].to_d
    @discount =0
    unless @coupon.blank? || @coupon.status == "Disabled"
      @coupon_text = @coupon.coupon_code
      if @coupon.coupon_type == 'Percentage'
        @discount = @order_total * (@coupon.discount.to_f / 100)
      else
        @discount = @coupon.discount
      end
      @total = @order_total 
    end
  end

  def apply_earning
    @earning = @current_user.earnings
    @order_total = params[:order_total].to_d
    @total = @order_total - @earning
  end

  def plan_details
    @plan = Plan.find_by_name(params[:plan_name])
  end

  def get_coupon
    @coupon = Coupon.find_by_coupon_code_and_year(params[:coupon_code],params[:coupon_validity].to_i/12)
    @order_total = params[:order_total].to_d unless params[:order_total].blank?
    @validity= params[:coupon_validity].to_d unless params[:coupon_validity].blank?
  end

  private

    def payment_transaction_reference
      #create the unique reference for transaction
      @sequence = TransactionSequence.create
      @sequence = Date.today.to_s(:number)+ pad_sequence(@sequence.id)
    end

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
