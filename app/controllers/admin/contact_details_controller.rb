class Admin::ContactDetailsController < ApplicationController
  require 'mail'
layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user
skip_after_filter :intercom_rails_auto_include
 def contacts
  # @menu = 'Reports'
  #   @page_name = 'Contact Details'
  #   @users = User.order("created_at DESC").page(params[:page]).per(20)
    @xls_users = User.order("created_at DESC")
    respond_to do |format|
      format.html 
      format.xls
      format.xml {render :xml => @users}
      format.json { render :json => ContactDetailsDatatable.new(view_context)}
    end
 end

end
