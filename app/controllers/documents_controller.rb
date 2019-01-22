class DocumentsController < ApplicationController
  def index
    if user_id = session[:current_user_id]
       #show only root folders (which have no parent folders)  
       @folders = @current_user.folders.roots   
       #show only root files which has no "folder_id"  
       @myfiles = @current_user.myfiles.where(:folder_id => nil).order("uploaded_file_file_name desc")
    end

    @myfile = Myfile.new      
    @folder = Folder.new
    @myfile.old_file_size = 0
    if params[:folder_id] 
      @current_folder = Folder.find(params[:folder_id])  
      @myfile.folder_id = @current_folder.id  
      @folder.parent_id = @current_folder.id
    end

  end
  
  
  
  #this action is for viewing folders  
  def browse
    #get the folders owned/created by the @current_user  
    
    @current_folder = @current_user.folders.find(params[:folder_id])    
    if @current_folder  
      @myfile = Myfile.new      
      @folder = Folder.new
      @myfile.old_file_size = 0
      @myfile.folder_id = @current_folder.id  
      @folder.parent_id = @current_folder.id
    #getting the folders which are inside this @current_folder  
       @folders = @current_folder.children  
     #We need to fix this to show files under a specific folder if we are viewing that folder  
       @myfiles = @current_folder.myfiles.order("uploaded_file_file_name desc")  
       render :action=> "index", :controller => "documents"  
     else  
       flash[:error] = "Don't be cheeky! Mind your own folders!"  
       redirect_to documents_index_url  
     end  
  end
  
  #this handles ajax request for inviting others to share folders  
  def share
    @menu = "Document"
    @page_name = "Share"
    #first, we need to separate the emails with the comma  
    email_addresses = params[:email_addresses].split(/[\,]/)
  
    
    email_addresses.each do |email_address|  
       #save the details in the ShareFolder table  
      @shared_folder = SharedFolders.new  
      @shared_folder.folder_id = params[:folder_id]  
      @shared_folder.shared_email = email_address  
      
      #getting the shared user id right the owner the email has already signed up with ShareBox  
      #if not, the field "shared_user_id" will be left nil for now.  
      shared_user = User.find_by_email(email_address)  
      @shared_folder.shared_user_id = shared_user.id if shared_user  
       
      @shared_folder.message = params[:message]  
      @shared_folder.save  
       
      #now send email to the recipients  
      Email.invitation_to_share(@shared_folder).deliver    
    end  
    #since this action is mainly for ajax (javascript request), we'll respond with js file back (refer to share.js.erb)  
    respond_to do |format|  
       format.js {  
         }  
    end  
  end  
  
end
