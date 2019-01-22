class InvitationDetailsController < ApplicationController
  # GET /invitation_details
  # GET /invitation_details.xml
  def index
    @menu = "Auditor"
    @page_name = "List auditor"
    @invitation_details = InvitationDetail.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @invitation_details }
    end
  end

  # GET /invitation_details/1
  # GET /invitation_details/1.xml
  def show
    @invitation_detail = InvitationDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @invitation_detail }
    end
  end

  # GET /invitation_details/new
  # GET /invitation_details/new.xml
  def new
    @menu = "Auditor"
    @page_name = "Invite an auditor"
    @invitation_detail = InvitationDetail.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @invitation_detail }
    end
  end

  # GET /invitation_details/1/edit
  def edit
    @invitation_detail = InvitationDetail.find(params[:id])
  end

  # POST /invitation_details
  # POST /invitation_details.xml
  def create
    @menu = "Auditor"
    @page_name = "Invite an auditor"
    invit_d = InvitationDetail.find_by_company_id_and_email_and_status_id(@company.id, params[:invitation_detail][:email], 0)
    
    require 'active_support/secure_random'
    @invitation_detail = InvitationDetail.new(params[:invitation_detail])
    @invitation_detail.company_id = @company.id
  	@invitation_detail.sent_by = @current_user.id
    @invitation_detail.token = SecureRandom.hex(8)

    respond_to do |format|
      if invit_d.blank? && @invitation_detail.save
		    Email.auditor_invitation(@invitation_detail).deliver
       format.js {render "/auditors/add_auditor"}
        # format.html { redirect_to(:controller => 'auditors', :action => 'index', :notice => 'Invitation detail was successfully created.') }
        flash[:success] = "Invitation mail has been sent to auditor"
        format.xml  { render :xml => @invitation_detail, :status => :created, :location => @invitation_detail }
      elsif !invit_d.blank?
        format.js {render "/auditors/add_auditor"}
        # format.html { redirect_to(:controller => 'auditors', :action => 'index')}
        flash[:notice] = "This auditor already invited."
      else
        format.js {render "/auditors/add_auditor"}
        format.html { render :action => "new" }
        format.xml  { render :xml => @invitation_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /invitation_details/1
  # PUT /invitation_details/1.xml
  def update
    @invitation_detail = InvitationDetail.find(params[:id])

    respond_to do |format|
      if @invitation_detail.update_attributes(params[:invitation_detail])
        format.html { redirect_to(@invitation_detail, :notice => 'Invitation detail was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @invitation_detail.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invitation_details/1
  # DELETE /invitation_details/1.xml
  def destroy
    @invitation_detail = InvitationDetail.find(params[:id])
    @invitation_detail.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => 'auditors', :action => 'index') }
      format.xml  { head :ok }
    end
  end
end
