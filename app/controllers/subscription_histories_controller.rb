class SubscriptionHistoriesController < ApplicationController
  # GET /subscription_histories
  # GET /subscription_histories.xml
  def index
    @subscription_histories = @company.subscription_histories

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subscription_histories }
    end
  end

  # GET /subscription_histories/1
  # GET /subscription_histories/1.xml
  def show
    @subscription_history = SubscriptionHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subscription_history }
    end
  end

  # GET /subscription_histories/new
  # GET /subscription_histories/new.xml
  def new
    @subscription_history = SubscriptionHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subscription_history }
    end
  end

  # GET /subscription_histories/1/edit
  def edit
    @subscription_history = SubscriptionHistory.find(params[:id])
  end

  # POST /subscription_histories
  # POST /subscription_histories.xml
  def create
    @subscription_history = SubscriptionHistory.new(params[:subscription_history])

    respond_to do |format|
      if @subscription_history.save
        format.html { redirect_to(@subscription_history, :notice => 'Subscription history was successfully created.') }
        format.xml  { render :xml => @subscription_history, :status => :created, :location => @subscription_history }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @subscription_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /subscription_histories/1
  # PUT /subscription_histories/1.xml
  def update
    @subscription_history = SubscriptionHistory.find(params[:id])

    respond_to do |format|
      if @subscription_history.update_attributes(params[:subscription_history])
        format.html { redirect_to(@subscription_history, :notice => 'Subscription history was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subscription_history.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /subscription_histories/1
  # DELETE /subscription_histories/1.xml
  def destroy
    @subscription_history = SubscriptionHistory.find(params[:id])
    @subscription_history.destroy

    respond_to do |format|
      format.html { redirect_to(subscription_histories_url) }
      format.xml  { head :ok }
    end
  end
end
