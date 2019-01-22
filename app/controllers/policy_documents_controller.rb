class PolicyDocumentsController < ApplicationController
 before_filter :menu_title
  # GET /policy_documents
  # GET /policy_documents.xml
  layout "payroll"
  #this action will let the users download the files (after a simple authorization check)
  def get
    policy_document = PolicyDocument.find_by_id(params[:id])
    if policy_document
      send_file policy_document.uploaded_file.path, :type => policy_document.uploaded_file_content_type
    else
      flash[:error] = "Don't be cheeky! Mind your own assets!"
      redirect_to policy_documents_path
    end
  end

  def index
    @search = @company.policy_documents.search(params[:search])
    @policy_documents = @search.order("uploaded_file_file_name desc").page(params[:page]).per(20)
    @policy_document = PolicyDocument.new
    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @policy_documents }
    end
  end

  # GET /policy_documents/1
  # GET /policy_documents/1.xml
  # def show
  # @menu = "Organisation"
  # @page_name = "Policy Documents"
  # @policy_document = PolicyDocument.find(params[:id])
  #
  # respond_to do |format|
  # format.html # show.html.erb
  # format.xml  { render :xml => @policy_document }
  # end
  # end

  # GET /policy_documents/new
  # GET /policy_documents/new.xml
   def new
   @policy_document = PolicyDocument.new
  
   @policy_document.old_file_size = 0
    respond_to do |format|
     format.html # new.html.erb
     format.xml  { render :xml => @policy_document }
    end
   end

  # GET /policy_documents/1/edit
  def edit
    @policy_document = PolicyDocument.find(params[:id])
    @policy_document.old_file_size = @policy_document.uploaded_file_file_size
  end

  # POST /policy_documents
  # POST /policy_documents.xml
  def create
    @policy_document = PolicyDocument.create_policy_document(params, @company, @current_user)
    respond_to do |format|
      if @policy_document.save
        @policy_document.register_user_action(request.remote_ip, 'created', @current_user.branch_id)
        format.html { redirect_to my_organisation_policy_document_path , :notice => 'Policy document successfully uploaded.'}
        format.xml  { render :xml => @policy_documents, :status => :created, :location => @policy_documents }
      else
        @search = @company.policy_documents.search(params[:search])
        @policy_documents = @search.order("uploaded_file_file_name desc")
        format.html { render :action => "index" }
        format.xml  { render :xml => @policy_documents.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /policy_documents/1
  # PUT /policy_documents/1.xml
  def update
    @policy_document = PolicyDocument.find(params[:id])
    @policy_document.old_file_size = params[:old_file_size]
    respond_to do |format|
      if @policy_document.update_attributes(params[:policy_document])
        @policy_document.register_user_action(request.remote_ip, 'updated', @current_user.branch_id)
        format.html { redirect_to(@policy_document, :notice => 'Policy document has been successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @policy_document.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /policy_documents/1
  # DELETE /policy_documents/1.xml
  def destroy
    @policy_document = PolicyDocument.find(params[:id])
    @policy_document.destroy
    @policy_document.register_user_action(request.remote_ip, 'deleted', @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to(my_organisation_policy_document_url, :notice => 'Policy document has been successfully deleted.') }
      format.xml  { head :ok }
    end
  end
end
private
def menu_title
  @menu ="My Organisation"
  @page_name = "Policy Document"
end