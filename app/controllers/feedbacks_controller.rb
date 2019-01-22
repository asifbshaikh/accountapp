class FeedbacksController < ApplicationController
  layout :chose_layout, :except => :new
  skip_before_filter :company_active?
  # GET /feedbacks
  # GET /feedbacks.xml
  def index
    @menu = "Feedback"
    @page_name = "Give Your Feedback"

    @feedbacks = Feedback.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @feedbacks }
    end
  end

  # GET /feedbacks/1
  # GET /feedbacks/1.xml
  def show
    @menu = "Feedback"
    @page_name = "User Feedback"
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  # GET /feedbacks/new
  # GET /feedbacks/new.xml
  def new
    #@menu = "Give Your Feedback"
    #@page_name = "Give Your Feedback"
    @feedback = Feedback.new
    #@user = User.find(params[:id])
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @feedback }
    end
  end

  # GET /feedbacks/1/edit
  def edit
    @menu = "Feedback"
    @page_name = "User Feedback"
    @feedback = Feedback.find(params[:id])
  end

  # POST /feedbacks
  # POST /feedbacks.xml
  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.company_id = @company.id
    @feedback.submitted_by = session[:current_user_id]
    respond_to do |format|
      if @feedback.save
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " new support voted as #{@feedback.vote}", "created", @current_user.branch_id)
        Email.feedback_created(@feedback, @current_user).deliver
        # format.html { redirect_to(@feedback, :notice => 'Feedback was successfully created.') }
        format.html { redirect_to :back, {:notice =>  'Feedback was successfully sent.'}}
        format.xml  { render :xml => @feedback, :status => :created, :location => @feedback }
      else
        @menu = "Feedback"
        @page_name = "User Feedback"
        format.html { render :action => "new" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /feedbacks/1
  # PUT /feedbacks/1.xml
  def update
    @feedback = Feedback.find(params[:id])

    respond_to do |format|
      if @feedback.update_attributes(params[:feedback])
         Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
         " support voted as #{@feedback.vote}", "updated", @current_user.branch_id)
        format.html { redirect_to(@feedback, :notice => 'Feedback was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = "Feedback"
        @page_name = "User Feedback"
        format.html { render :action => "edit" }
        format.xml  { render :xml => @feedback.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /feedbacks/1
  # DELETE /feedbacks/1.xml
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy
    Workstream.register_user_action(@company.id, @current_user.id, request.remote_ip,
    " support voted as #{@feedback.vote}", "deleted", @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(feedbacks_url) }
      format.xml  { head :ok }
    end
  end

  private

  def chose_layout
    session[:current_app_id] == 1 ? 'application' : 'payroll'
  end
end
