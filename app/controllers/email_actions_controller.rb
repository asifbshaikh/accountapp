class EmailActionsController < ApplicationController
  # GET /email_actions
  # GET /email_actions.xml
  def index
    @email_actions = EmailAction.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @email_actions }
    end
  end

  # GET /email_actions/1
  # GET /email_actions/1.xml
  def show
    @email_action = EmailAction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @email_action }
    end
  end

  # GET /email_actions/new
  # GET /email_actions/new.xml
  def new
    @email_action = EmailAction.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @email_action }
    end
  end

  # GET /email_actions/1/edit
  def edit
    @email_action = EmailAction.find(params[:id])
  end

  # POST /email_actions
  # POST /email_actions.xml
  def create
    @email_action = EmailAction.new(params[:email_action])

    respond_to do |format|
      if @email_action.save
        format.html { redirect_to(@email_action, :notice => 'Email action was successfully created.') }
        format.xml  { render :xml => @email_action, :status => :created, :location => @email_action }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @email_action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /email_actions/1
  # PUT /email_actions/1.xml
  def update
    @email_action = EmailAction.find(params[:id])

    respond_to do |format|
      if @email_action.update_attributes(params[:email_action])
        format.html { redirect_to(@email_action, :notice => 'Email action was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @email_action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /email_actions/1
  # DELETE /email_actions/1.xml
  def destroy
    @email_action = EmailAction.find(params[:id])
    @email_action.destroy

    respond_to do |format|
      format.html { redirect_to(email_actions_url) }
      format.xml  { head :ok }
    end
  end

  def email_template
  end
end
