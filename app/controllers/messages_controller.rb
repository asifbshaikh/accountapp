class MessagesController < ApplicationController

  # layout :chose_layout
  # GET /messages
  # GET /messages.xml
  def index
    @message = Message.new
    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @messages }
      format.json { render :json => MessagesDatatable.new(view_context, @company, @current_user)}
    end
  end

  # GET /messages
  # GET /messages.xml
  def sent
   @messages = Message.sent_messages( @company.id, @current_user.id).page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  # GET /messages
  # GET /messages.xml
  def draft
   @messages = @company.messages.order(:created_at).where(" created_by = ? and status = 2", @current_user.id).page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.xml
  def show
   @message = Message.find(params[:id])
    @replies = Message.find_all_replies @message
    @message.status = 1
    @message.save

    @reply = Message.new
    respond_to do |format|
      format.html # show.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.xml
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
  end

  # POST /messages
  # POST /messages.xml
  def create
    @message = Message.new(params[:message])
    @message.created_by = @current_user.id
    @message.company_id = @company.id
    @message.status = 0
    respond_to do |format|
      if @message.save
        flash[:success] = "Message Successfully sent to #{@message.to}"
        format.html { redirect_to(messages_url,:notice =>"Message sent successfully") }
        format.xml  { render :xml => @message, :status => :created, :location => @message }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.xml
  def update
    @message = Message.find(params[:id])
    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to(messages_url, :notice => 'Message was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @message.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    msg = Message.find(params[:id])
    msg.destroy
    respond_to do |format|
      format.html { redirect_to(messages_url) }
      flash[:success]= "Message deleted successfully"
      format.xml  { head :ok }
    end
  end

  

end
