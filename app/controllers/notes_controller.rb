class NotesController < ApplicationController
  layout :chose_layout
  
  # GET /notes
  # GET /notes.xml
  def index
    @menu = "Notes"
    @page_name = "Notes List"
    @tags = Note.where("created_by = ?", @current_user.id).tag_counts
    @notes = @current_user.notes.page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
    end
  end
  
  def tag
    @menu = "Notes"
    @page_name = "Notes List"
    @search = @current_user.notes.search(params[:search])
    @tags = Note.where("created_by = ? ", @current_user.id).tag_counts
    @notes = Note.tagged_with(params[:id]).page(params[:page]).per(20)
    respond_to do |format|
      format.html # tag.html.erb
      format.xml  { render :xml => @notes }
    end
  end

  def deleted_notes
    @menu = "Notes"
    @page_name = "Deleted Notes "
    @users = @company.users
    @notes = Note.deleted_notes
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
    end  
  end
  
  # GET /notes/1
  # GET /notes/1.xml
  def show
    @menu = "Notes"
    @page_name = "Note Detail "
    @note = Note.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @note }
    end
  end
  
  # GET /notes/new
  # GET /notes/new.xml
  def new
    @menu = "Notes"
    @page_name = "Create New Note "
    @users = @company.users
    @note = Note.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end
  
  # GET /notes/1/edit
  def edit
    @menu = "Notes"
    @page_name = "Edit Note"
    @note = Note.find(params[:id])
    @users = @company.users 
  end
  
  # POST /notes
  # POST /notes.xml
  def create
    @note = Note.new(params[:note])
    #tags = params[:tag_list]
    @note.created_by = @current_user.id
    @note.company_id =  @company.id
    @note.status = "undeleted"
    respond_to do |format|
      if @note.save
        flash[:success] = 'Your note was saved successfully!'
        format.html { redirect_to(notes_path) }
        format.xml  { render :xml => @note, :status => :created, :location => @note }
      else
        @menu = "Notes"
        @page_name = "Create New Note "
        format.html { render :action => "new" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = Note.find(params[:id])
    
    respond_to do |format|
      if @note.update_attributes(params[:note])
        format.html { redirect_to(@note, :notice => 'Note successfully updated.') }
        format.xml  { head :ok }
      else
         @menu = "Notes"
         @page_name = "Edit Note "
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = Note.find(params[:id])
    @note.status = "deleted"
    @note.save
    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.xml  { head :ok }
    end
  end
  
  private 

    def chose_layout
      session[:current_app_id] == 1 ? 'application' : 'payroll'
    end
  
  
end
