class FoldersController < ApplicationController
  #before_filter :authenticate_user!
# layout :chose_layout, :except => :new
  def index
    @menu = "Share Document"
    @page_name= "Folders"
    @folders = @current_user.folders#.find_all_by_user_id(session[:current_user_id].to_i)
  #@folders = Folder.all
  end

  def show
    @menu = "Share Document"
    @page_name= "View Folder"
    @folder = Folder.find(params[:id])
  #@folder = Folder.find(params[:id])
  end

  def new
    @menu = "Document"
    @page_name= "Create New Folder"
    @folder = Folder.new
    #if there is "folder_id" param, we know that we are under a folder, thus, we will essentially create a subfolder
    if params[:folder_id]#if we want to create a folder inside another folder
      #we still need to set the @current_folder to make the buttons working fine
      @current_folder = Folder.find(params[:folder_id])

    #then we make sure the folder we are creating has a parent folder which is the @current_folder
    @folder.parent_id = @current_folder.id
    end
  end

  def create
    @folder = Folder.new(params[:folder])
    @folder.user_id = @current_user.id
    if @folder.save
      flash[:notice] = "Successfully created folder."
      if @folder.parent#checking if we have a parent folder on this one
        redirect_to browse_path(@folder.parent)
      else
        redirect_to documents_index_path
      end
    else
      @myfiles = @current_user.myfiles.where(:folder_id => nil).order("uploaded_file_file_name desc")         
      @folders = @current_user.folders.roots
      @myfile = Myfile.new      
      @myfile.old_file_size = 0
      render "/documents/index"
      
    end
  end

  def edit
    @menu = "Document"
    @page_name= "Rename Folder"
    @folder = Folder.find(params[:folder_id])
    @current_folder = @folder.parent #this is just for breadcrumbs

  end

  def update
    @folder = Folder.find(params[:id])
    #@folder = Folder.find(params[:id])
    if @folder.update_attributes(params[:folder])
      redirect_to documents_index_url
    else
      @menu = "Share Document"
      @page_name= "Rename Folder"
      redirect_to documents_index_path
    end
  end

  def destroy
    @folder = Folder.find(params[:id])
    @parent_folder = @folder.parent #grabbing the parent folder
    #this will destroy the folder along with all the contents inside
    #sub folders will also be deleted too as well as all files inside
    @folder.destroy
    flash[:notice] = "Successfully deleted the folder and all the contents inside."

    #redirect to a relevant path depending on the parent folder
    if @parent_folder
      redirect_to browse_path(@parent_folder)
    else
      redirect_to documents_index_path
    end
  end
  private

  def chose_layout
    session[:current_app_id] == 1 ? 'application' : 'payroll'
  end
end
