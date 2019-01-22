class Admin::CouponsController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user
  skip_before_filter :check_if_allow  
  skip_after_filter :intercom_rails_auto_include, :intercom_events

  def index
    @menu = 'Coupon'
    @page_name = 'List of coupons'
    @coupons = Coupon.order("id desc")#.page(page)#.per(per_page)
    respond_to do |format|
      format.html #coupons.html.erb
      format.xml  { render :xml => @coupons }
    end
  end

  def new
    @menu = 'Coupon'
    @page_name = 'Create new coupon'
    @coupon = Coupon.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coupons }
    end
  end

  def show
    @menu = 'Coupon'
    @page_name = 'Coupon details'
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coupon }
    end
  end

  def edit
    @menu = 'Coupon'
    @page_name = 'Edit coupon'
    @coupon = Coupon.find(params[:id])
  end

  def create
    @coupon = Coupon.new(params[:coupon])
    respond_to do |format|
      if @coupon.save
        flash[:success]= "Coupon successfully created."
        format.html { redirect_to admin_coupons_url }
        format.xml  { render :xml => @coupon, :status => :created, :location => @coupon }
      else
       @menu = 'Coupon'
       @page_name = 'Create new coupon'
       format.html { render :action => "new" }
       format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
     end
   end
 end


 def update
  @coupon = Coupon.find(params[:id])

  respond_to do |format|
    if @coupon.update_attributes(params[:coupon])
      format.html { redirect_to(admin_coupons_url, :notice => 'Coupon was successfully updated.') }
      format.xml  { head :ok }
    else
     @menu = 'Coupon'
     @page_name = 'Edit coupon'
     format.html { render :action => "edit" }
     format.xml  { render :xml => @coupon.errors, :status => :unprocessable_entity }
   end
 end
end

  # DELETE /assets/1
  # DELETE /assets/1.xml
  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy
    respond_to do |format|
      format.html { redirect_to(admin_coupons_url) }
      format.xml  { head :ok }
    end
  end

  private

    def page
      params[:iDisplayStart].to_i / per_page + 1
    end

    def per_page
      params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 25
    end

end
