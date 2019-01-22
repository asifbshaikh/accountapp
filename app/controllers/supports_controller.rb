class SupportsController < ApplicationController
  layout :chose_layout #, :except => :new
  skip_before_filter :company_active?
  # GET /supports
  # GET /supports.xml
  def index
    @menu = 'Support'
    @page_name = 'Support ticket'
    @search = @company.supports.search(params[:search])
    @supports = @search.where(:reply_id => nil, :deleted => false).page(params[:page]).per(20)
    #@supports = Support.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @supports }
    end
  end

  # GET /supports/1
  # GET /supports/1.xml
  def show
    @menu = 'Support'
    @page_name = 'Support ticket'
    @support = Support.find(params[:id])
    @replies = @company.supports.where(:ticket_number => @support.ticket_number).page(params[:page]).per(20)
    @reply = Support.new
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @support }
    end
  end

  # GET /supports/new
  # GET /supports/new.xml
  def new
     @menu = 'Support'
     @page_name = 'Support ticket'
     @support = Support.new
     super_user = SuperUser.first
     @support.ticket_number = "TKT"+Time.now.to_i.to_s
     @support.assigned_to = super_user.id
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @support }
    end
  end

  # GET /supports/1/edit
  def edit
      @menu = 'Support'
      @page_name = 'Support ticket'
      @support = Support.find(params[:id])
  end

  # POST /supports
  # POST /supports.xml
  def create
    @support = Support.new(params[:support])
    @support.company_id = @company.id
    @support.created_by = @current_user.id
    @support.status_id = 0
    @support.created_date = Date.today
    respond_to do |format|
      if @support.save
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " New support ticket #{@support.ticket_number} created by #{ @support.created_by}", "created",@current_user.branch_id)
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

  # PUT /supports/1
  # PUT /supports/1.xml
  def update
    @support = Support.find(params[:id])
    @support.completed_date = Date.today
    @support.status_id = 1
    respond_to do |format|
      if @support.update_attributes(params[:support])
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
        " support ticket #{@support.ticket_number} updated by #{ @support.created_by}", "updated",@current_user.branch_id)
        format.html { redirect_to(@support, :notice => 'Support was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Support'
        @page_name = 'Support ticket'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @support.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /supports/1
  # DELETE /supports/1.xml
  def permanent_delete
    Support.permanent_delete(params[:ticket_number])
    respond_to do |format|
      format.html { redirect_to(supports_url) }
      flash[:success]= "Support ticket deleted successfully"
      format.xml  { head :ok }
    end
  end

 private

  def chose_layout
    session[:current_app_id] == 1 ? 'application' : 'payroll'
  end
end
