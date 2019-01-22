class Admin::SupportsController < ApplicationController
  layout "admin"
  skip_before_filter  :authorize_action, :authenticate, :company_active?, :check_if_allow, :current_financial_year
  before_filter :authorize_super_user

  def index
    @menu = 'Support'
    @page_name = 'Support ticket list'
    @supports = Support.where(:reply_id => nil, :deleted => false).order("created_at DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html #company_details.html.erb
      format.xml  { render :xml => @supports }
    end
  end

  def show
     @menu = 'Support'
     @page_name = 'Support ticket details'
     @support = Support.find(params[:id])
     @replies = Support.where(:ticket_number => @support.ticket_number).page(params[:page]).per(20)
     @reply = Support.new
     respond_to do |format|
       format.html # show.html.erb
       format.xml  { render :xml => @support }
     end
  end

 def edit
   @menu = 'Support'
   @page_name = 'Resolve support ticket'
   @support = Support.find(params[:id])
 end

# POST /supports
  # POST /supports.xml
  def create
    @support = Support.new(params[:support])
    super_user = SuperUser.first
    @support.created_by = super_user.id
    @support.status_id = 0
    @support.created_date = Time.zone.now.to_date
    respond_to do |format|
      if @support.save
         support = Support.find_by_id(@support.reply_id)
         support.update_attribute(:status_id, 1)
         support.save
        format.html { redirect_to :back, { :notice => 'Support was successfully created.'} }
        format.xml  { render :xml => @support, :status => :created, :location => @support }
      else
        @menu = 'Support'
        @page_name = 'Support ticket'
        format.html { render :action => "new" }
        format.xml  { render :xml => @support.errors, :status => :unprocessable_entity }
      end
    end
  end

  def close_ticket
   Support.close_ticket(params[:ticket_number])
   flash[:now]= "Ticket closed successfully"
   redirect_to :back
 end

 def update
    @support = Support.find(params[:id])
    @support.completed_date = Time.zone.now.to_date
    @support.status_id = 2
    respond_to do |format|
      if @support.update_attributes(params[:support])
        format.html { redirect_to(admin_supports_path, :notice => 'Support was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Support'
        @page_name = 'Support ticket'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @support.errors, :status => :unprocessable_entity }
      end
    end
  end

 def permanent_delete
    Support.permanent_delete(params[:ticket_number])
    respond_to do |format|
      format.html { redirect_to(admin_supports_url) }
      flash[:success]= "Support ticket deleted successfully"
      format.xml  { head :ok }
    end
  end

end