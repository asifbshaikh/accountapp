class Admin::ProfitbooksWorkstreamsController < ApplicationController

  layout "admin"
  skip_before_filter :company_from_subdomain, :authorize_action, :authenticate, :company_active?, :check_if_allow, :check_messages, :company_from_subdomain, :current_financial_year, :mix_panel_track
  before_filter :authorize_super_user
  skip_after_filter :intercom_rails_auto_include

  def index
    @product_updates = ProfitbooksWorkstream.order("release_date DESC").page(params[:page]).per(5)
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def new
    @product_update = ProfitbooksWorkstream.new(:status => 0)
  end

  def edit
    @product_update = ProfitbooksWorkstream.find(params[:id])
  end

  def create
    @product_update = ProfitbooksWorkstream.new(params[:profitbooks_workstream])
    @product_update.created_by = session[:current_super_user_id].to_i
    if(params[:draft])
      @product_update.status = ProfitbooksWorkstream::STATUS[:draft]
    else
      @product_update.status = ProfitbooksWorkstream::STATUS[:published]
    end
    respond_to do |format|
      if @product_update.save
        flash[:success]= "You successfully added a new product update."
        format.html { redirect_to admin_profitbooks_workstreams_path }
      else
       format.html { render :action => "new" }
      end
    end
  end

  def update
    @product_update = ProfitbooksWorkstream.find(params[:id])
    respond_to do |format|
      if @product_update.update_attributes(params[:profitbooks_workstream])
        flash[:success]= "You successfully updated the product update."
        format.html { redirect_to admin_profitbooks_workstreams_path }
      else
       format.html { render :action => "index" }
      end
    end
  end

  def destroy
    @product_update = ProfitbooksWorkstream.find(params[:id])
    @product_update.destroy
    flash[:success] = 'The product update has been successfully deleted.'
  end

  def publish
    @product_update = ProfitbooksWorkstream.find(params[:id])
    @product_update.publish()
    flash[:success] = 'The product update has been successfully posted.'
  end

  def archive
    @product_update = ProfitbooksWorkstream.find(params[:id])
    @product_update.archive()
    flash[:success] = 'The product update has been successfully archived.'
  end

end
