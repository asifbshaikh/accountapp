class HelpsController < ApplicationController

  layout :chose_layout, :except => :show
  # GET /helps
  # GET /helps.xml
  def index
    @menu = "Help"
    @page_name = "View Help"
    @helps = Help.order(:screen_id).page(params[:page]).per(5)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @helps }
    end
  end

  # GET /helps/1
  # GET /helps/1.xml
  def show
    @menu = "Help"
    @page_name = "Show Help"
    @help = Help.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @help }
    end
  end

  # GET /helps/new
  # GET /helps/new.xml
  def new
    @menu = "Help"
    @page_name = "Add New Help"
    @help = Help.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @help }
    end
  end

  # GET /helps/1/edit
  def edit
    @menu = "Help"
    @page_name = "Edit Help"
    @help = Help.find(params[:id])
  end

  # POST /helps
  # POST /helps.xml
  def create
    @help = Help.new(params[:help])

    respond_to do |format|
      if @help.save
        format.html { redirect_to(@help, :notice => 'Help was successfully created.') }
        format.xml  { render :xml => @help, :status => :created, :location => @help }
      else
        @menu = "Help"
        @page_name = "Add New Help"
        format.html { render :action => "new" }
        format.xml  { render :xml => @help.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /helps/1
  # PUT /helps/1.xml
  def update
    @help = Help.find(params[:id])

    respond_to do |format|
      if @help.update_attributes(params[:help])
        format.html { redirect_to(@help, :notice => 'Help was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @help.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /helps/1
  # DELETE /helps/1.xml
  def destroy
    @help = Help.find(params[:id])
    @help.destroy

    respond_to do |format|
      format.html { redirect_to(helps_url) }
      format.xml  { head :ok }
    end
  end
  private

  def chose_layout
    session[:current_app_id] == 1 ? 'application' : 'payroll'
  end
end
