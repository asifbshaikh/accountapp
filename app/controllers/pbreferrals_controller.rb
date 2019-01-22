class PbreferralsController < ApplicationController
  # GET /pbreferrals
  # GET /pbreferrals.json
  def index
    @pbreferral = Pbreferral.new
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pbreferrals }
      format.json { render :json => PbreferralDatatable.new(view_context, @company, @current_user)}
    end
  end

  # GET /pbreferrals/1
  # GET /pbreferrals/1.json
  def show
    @pbreferral = Pbreferral.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @pbreferral }
    end
  end

  # GET /pbreferrals/new
  # GET /pbreferrals/new.json
  def new
    @pbreferral = Pbreferral.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @pbreferral }
    end
  end

  # GET /pbreferrals/1/edit
  def edit
    @pbreferral = Pbreferral.find(params[:id])
  end

  # POST /pbreferrals
  # POST /pbreferrals.json
  def create
    require 'active_support/secure_random'
    ActiveRecord::Base.transaction do
    @referral_emails = params[:referral_emails].split(/,\s*/)
    if @referral_emails.blank?
      flash[:error]="Please enter atleast 1 invitee"
    else
      coupon_code = "REFBY"+@current_user.email
      coupon = Coupon.find_by_coupon_code_and_coupon_type(coupon_code, "Referral")
      if coupon.blank?
        coupon = Coupon.create_referral_coupon(@current_user.email, @referral_emails.count)
      else
        new_count= coupon.uses_per_coupon + @referral_emails.count
        coupon.update_attributes(:uses_per_coupon => new_count, :date_end => 30.days.from_now)
      end
      @referral_emails.each do |email|
          @pbreferral = Pbreferral.new(params[:pbreferral])
          @pbreferral.company_id = @company.id
          @pbreferral.invited_by = @current_user.id
          @pbreferral.coupon_id = coupon.id
          @pbreferral.email = email
          @pbreferral.token = SecureRandom.hex(8)
          if @pbreferral.save
            @pbreferral.register_user_action(request.remote_ip, "created", @current_user)
            Email.refer_pb(@pbreferral).deliver
            flash[:notice] ="Invitation sent successfully to #{@pbreferral.email}"
          else
            flash[:error] = "Invitation failed to #{@pbreferral.email}"
          end
        end
        # creating and updating user_referral on new invitation
        UserReferral.maintain_detail(@pbreferral.company_id, @pbreferral.invited_by, @referral_emails.count)
      end
      redirect_to pbreferrals_path
    end
  end

  # PUT /pbreferrals/1
  # PUT /pbreferrals/1.json
  def update
    @pbreferral = Pbreferral.find(params[:id])

    respond_to do |format|
      if @pbreferral.update_attributes(params[:pbreferral])
        format.html { redirect_to @pbreferral, :notice => 'Pbreferral was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @pbreferral.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pbreferrals/1
  # DELETE /pbreferrals/1.json
  def destroy
    @pbreferral = Pbreferral.find(params[:id])
    @pbreferral.destroy

    respond_to do |format|
      format.html { redirect_to pbreferrals_url }
      format.json { head :ok }
    end
  end

end
