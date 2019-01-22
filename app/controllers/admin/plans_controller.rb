class Admin::PlansController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user
skip_after_filter :intercom_rails_auto_include
  def index
    @menu = "Plans"
    @page_name = "List of Plans"
    
    @plans = Plan.order(:display_name)
    @roles = @plans.first.roles
    @granted_rights = Grant.where(:role_id => @roles.first.id)
    @right_ids = []
    @granted_rights.each do |right|
      @right_ids<<right.right_id
    end
    @ungranted_rights = Right.where("id NOT IN (?)", @right_ids)
  end
  
  def grant
    @role = Role.find params[:grant][:role_id]
    params[:right].each do |right|
      grant = Grant.find_by_role_id_and_right_id(@role.id, right.to_i)
      grant.delete unless grant.blank? 
    end
    
    params[:grant][:right_id].each do |right|
      
    end
    redirect_to "/admin/plans/index"
  end
  
  def get_role
    @plan = Plan.find params[:plan_id]
    @roles = @plan.roles
    @granted_rights = Grant.where(:role_id => @roles.first.id)
    @right_ids = []
    @granted_rights.each do |right|
      @right_ids<<right.right_id
    end
    @ungranted_rights = Right.where("id NOT IN (?)", @right_ids)
  end
  
  def get_right
    @role = Role.find params[:role_id]
     @granted_rights = Grant.where(:role_id => @role.id)
     @right_ids = []
    @granted_rights.each do |right|
      @right_ids<<right.right_id
    end
    @ungranted_rights = Right.where("id NOT IN (?)", @right_ids)
  end
end
