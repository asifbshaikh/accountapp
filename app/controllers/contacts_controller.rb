class ContactsController < ApplicationController
  layout :chose_layout
  # GET /contacts
  # GET /contacts.xml
  def index
    @menu = 'Contacts'
    @page_name = 'Contact List'
    @users = User.users_in_company(session[:current_user_id])
    @search = Contact.search(params[:search])
    @contacts = @search.page(params[:page]).per(1)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contacts }
    end
  end

  # GET /contacts/1
  # GET /contacts/1.xml
  def show
    @menu = 'Contacts'
    @page_name = 'View contact'
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/new
  # GET /contacts/new.xml
  def new
    @menu = 'Contacts'
    @page_name = 'Create new contact'
    @users = User.users_in_company(session[:current_user_id])
    @contact = Contact.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contact }
    end
  end

  # GET /contacts/1/edit
  def edit
    @menu = 'Contacts'
    @page_name = 'Edit contact'
    @contact = Contact.find(params[:id])
    @users = User.users_in_company(session[:current_user_id])
  end

  # POST /contacts
  # POST /contacts.xml
  def create
    @contact = Contact.new(params[:contact])

    respond_to do |format|
      if @contact.save
        format.html { redirect_to(@contact, :notice => 'Contact was successfully created.') }
        format.xml  { render :xml => @contact, :status => :created, :location => @contact }
      else
        @menu = 'Contacts'
        @page_name = 'Create new contact'
        format.html { render :action => "new" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contacts/1
  # PUT /contacts/1.xml
  def update
    @contact = Contact.find(params[:id])

    respond_to do |format|
      if @contact.update_attributes(params[:contact])
        format.html { redirect_to(@contact, :notice => 'Contact was successfully updated.') }
        format.xml  { head :ok }
      else
        @menu = 'Contacts'
        @page_name = 'Edit contact'
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contact.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.xml
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy

    respond_to do |format|
      format.html { redirect_to(contacts_url) }
      format.xml  { head :ok }
    end
  end

  private

  def chose_layout
    session[:current_app_id] == 1 ? 'application' : 'payroll'
  end

end
