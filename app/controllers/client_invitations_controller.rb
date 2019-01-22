class ClientInvitationsController < ApplicationController
  require 'active_support/secure_random'

  skip_before_filter :company_from_subdomain, :authenticate, :user_from_session, :only => [:index, :authenticate, :switch, :check_password, :accept_request, :create,:rejected_client, :destroy]
  skip_before_filter :authorize_action,  :check_messages, :check_if_allow, :current_financial_year, :mix_panel_track
  skip_before_filter :company_active?
  skip_before_filter :check_active_session?, :only => :index
  skip_after_filter  :intercom_rails_auto_include
  skip_before_filter :verify_authenticity_token, :only => [:check_password]

  layout 'auditor'

  # GET /client_invitations
  # GET /client_invitations.xml
  def index
    @auditor = Auditor.find session[:current_auditor_id]
    @companies = @auditor.companies
    @client_invitations = @auditor.client_invitations.where(:status_id => [0,1,2])
    #@client_invitations = @auditors.client_invitations
    @client_invitation = ClientInvitation.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @client_invitations }
    end
  end

  # GET /client_invitations/1
  # GET /client_invitations/1.xml
  def show
    @client_invitation = ClientInvitation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @client_invitation }
    end
  end

  # GET /client_invitations/new
  # GET /client_invitations/new.xml
  def new
    @menu = "client"
    @page_name = "Invite an client"
    @client_invitation = ClientInvitation.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @client_invitation }
    end
  end

  # GET /client_invitations/1/edit
  def edit
    @client_invitation = ClientInvitation.find(params[:id])
  end

  # POST /client_invitations
  # POST /client_invitations.xml
  def create
    
    @page_name = "Invite an client"
    #logger.debug "Inside controller : #{session[:current_auditor.email]}------------------------"
    #need code for checking if client already present
    
    
    @client_invitation = ClientInvitation.new(params[:client_invitation])
    @client_invitation.auditor_id = session[:current_auditor_id]
    @client_invitation.sent_by = session[:current_auditor_id] 
       #@client_invitation.sent_by = @current_auditor.email
    @client_invitation.token = SecureRandom.hex(8)

    respond_to do |format|
      if @client_invitation.save
        Email.client_invitation(@client_invitation).deliver
        format.js {render "/auditors/add_client"}
        format.html { redirect_to(:controller => 'client_invitations', :action => 'index') }
        flash[:success] = "Invitation mail has been sent to client"
        
      # elsif !invit_d.blank?
      #   format.js {render "/auditors/add_client"}
      #   # format.html { redirect_to(:controller => 'auditors', :action => 'index')}
      #   flash[:notice] = "This client already invited."
      else
        format.js {render "/auditors/add_client"}
        format.html { render :action => "new" }
        
      end
    end
  end

  # PUT /client_invitations/1
  # PUT /client_invitations/1.xml
  def update
    @client_invitation = ClientInvitation.find(params[:id])

    respond_to do |format|
      if @client_invitation.update_attributes(params[:client_invitation])
        format.html { redirect_to(@client_invitation, :notice => 'Invitation detail was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @client_invitation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /client_invitations/1
  # DELETE /client_invitations/1.xml
  def destroy
    
    @client_invitation = ClientInvitation.find(params[:id])
    
    @client_invitation.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => 'client_invitations', :action => 'index') }
      format.xml  { head :ok }
    end
  end

  def rejected_client
    @invitation = ClientInvitation.find(params[:id])
    if @invitation.present?
      
     @invitation.decline
   end
   respond_to do |format|
     format.html { redirect_to(:controller => 'login', :action => 'index')}  
   end    
  end
end
