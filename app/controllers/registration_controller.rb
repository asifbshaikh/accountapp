class RegistrationController < ApplicationController
  def index
  end

  def new
    @company = Company.new
    1.times {@company.users.build}
  end

  def create
    @company = Company.new(params[:company])
    respond_to do |format|
      if @company.save
        format.html { redirect_to(:index, :notice => 'Registration was successfully created.') }
        format.xml  { render :xml => :index, :status => :created, :location => @company }
        Email.registration_confirmation(@user).deliver
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end

  end

end
