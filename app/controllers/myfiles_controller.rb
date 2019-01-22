class MyfilesController < ApplicationController
  # GET /myfiles
  # GET /myfiles.xml
# layout :chose_layout, :except => :new
      #this action will let the users download the files (after a simple authorization check)  
  def get  
    myfile = @current_user.myfiles.find_by_id(params[:id])  
    if myfile  
         send_file myfile.uploaded_file.path, :type => myfile.uploaded_file_content_type  
    else  
      flash[:error] = "Don't be cheeky! Mind your own assets!"  
      redirect_to documents_index_url  
    end    
  end  
  
  def index
    @menu = "Share Document"
    @page_name = "Uploaded File"
    @myfiles = @current_user.myfiles

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @myfiles }
    end
  end

  # GET /myfiles/1
  # GET /myfiles/1.xml
  def show
    @menu = "Share Document"
    @page_name = "Uploaded File"
    @myfile = Myfile.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @myfile }
    end
  end

  # GET /myfiles/new
  # GET /myfiles/new.xml
  def new
    @menu = "Document"
    @page_name = "Upload New File"
    @myfile = Myfile.new      
    @myfile.old_file_size = 0
    if params[:folder_id] #if we want to upload a file inside another folder  
      @current_folder = Folder.find(params[:folder_id])  
      @myfile.folder_id = @current_folder.id  
    end  
   respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @myfile }
    end
  end

  # GET /myfiles/1/edit
  def edit
    @myfile = Myfile.find(params[:id])
    @myfile.old_file_size = @myfile.uploaded_file_file_size
  end

  # POST /myfiles
  # POST /myfiles.xml
  def create  
      @myfile = Myfile.upload_file(params, @company, @current_user)
      # @myfile.company_id = @company.id
      # @myfile.user_id = @current_user.id
      # @myfile.old_file_size = 0
      if @myfile.save  
       flash[:notice] = "Successfully uploaded the file."  
       @myfile.register_user_action(request.remote_ip, 'created', @current_user.branch_id)
       if @myfile.folder #checking if we have a parent folder for this file  
         redirect_to browse_path(@myfile.folder)  #then we redirect to the parent folder  
       else  
         redirect_to documents_index_url  
       end        
      else  
        @folders = @current_user.folders.roots   
        #show only root files which has no "folder_id"  
        @myfiles = @current_user.myfiles.where(:folder_id => nil).order("uploaded_file_file_name desc")         
        @folder = Folder.new
        if params[:folder_id] 
          @current_folder = Folder.find(params[:folder_id])  
          @folder.parent_id = @current_folder.id
        end
        render "/documents/index"
      end  
  end  

  # PUT /myfiles/1
  # PUT /myfiles/1.xml
  def update
    @myfile = Myfile.find(params[:id])

    @myfile.old_file_size = params[:old_file_size]
    respond_to do |format|
      if @myfile.update_attributes(params[:myfile])
        @myfile.register_user_action(request.remote_ip, 'updated', @current_user.branch_id)
        format.html { redirect_to(@myfile, :notice => 'Myfile was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @myfile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /myfiles/1
  # DELETE /myfiles/1.xml
  def destroy
    @myfile = Myfile.find(params[:id])
    @parent_folder = @myfile.folder #grabbing the parent folder before deleting the record  
    @myfile.destroy  
    @myfile.register_user_action(request.remote_ip, 'deleted', @current_user.branch_id)
    flash[:notice] = "Successfully deleted the file." 

   #redirect to a relevant path depending on the parent folder  
   if @parent_folder  
     redirect_to browse_path(@parent_folder)  
   else  
     redirect_to documents_index_url  
    end  
  end
   private 

    def chose_layout
      session[:current_app_id] == 1 ? 'application' : 'payroll'
    end
end
