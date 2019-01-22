class WebinarsController < ApplicationController
  layout :false
  #to skip checking the authentication and authorization.
  skip_before_filter  :authorize_action, :authenticate, :check_messages, :check_if_allow
  skip_before_filter :company_active?
  before_filter :check_active_session?, :only => :index
  skip_after_filter :intercom_rails_auto_include  

  # GET /webinars
  # GET /webinars.json
  def index
    @webinars = Webinar.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @webinars }
    end
  end

  # GET /webinars/1
  # GET /webinars/1.json
  def show
    @webinar = Webinar.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @webinar }
    end
  end

  # GET /webinars/new
  # GET /webinars/new.json
  def new
    @webinar = Webinar.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @webinar }
    end
  end

  # GET /webinars/1/edit
  def edit
    @webinar = Webinar.find(params[:id])
  end

  # POST /webinars
  # POST /webinars.json
  def create
    @webinar = Webinar.new(params[:webinar])

    respond_to do |format|
      if @webinar.save

       if (Email.webinar_registration(@webinar.name, @webinar.email, @webinar.phone).deliver)
        Email.webinar_confirmation_to_user(@webinar.name, @webinar.email, @webinar.phone).deliver
       end
        format.html { redirect_to :action=>"new" }
        format.json { render :json => @webinar, :status => :created, :location => @webinar }
        flash[:success] ="Your request for ProfitBooks webinar submitted successfully"
      else
        format.html { render :action => "new" }
        format.json { render :json => @webinar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /webinars/1
  # PUT /webinars/1.json
  def update
    @webinar = Webinar.find(params[:id])

    respond_to do |format|
      if @webinar.update_attributes(params[:webinar])
        format.html { redirect_to @webinar, :notice => 'Webinar was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @webinar.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /webinars/1
  # DELETE /webinars/1.json
  def destroy
    @webinar = Webinar.find(params[:id])
    @webinar.destroy

    respond_to do |format|
      format.html { redirect_to webinars_url }
      format.json { head :ok }
    end
  end
end
