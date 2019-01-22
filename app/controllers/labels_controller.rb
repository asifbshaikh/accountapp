class LabelsController < ApplicationController
  before_filter :menu_title
  # GET /labels
  # GET /labels.xml
  def index
    @labels = @company.labels.page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @labels }
    end
  end

  # GET /labels/1
  # GET /labels/1.xml
  def show
    @label = @company.label
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @label }
    end
  end
  # GET /labels/new
  # GET /labels/new.xml
  def new
    @label = Label.new_record(@current_user.id)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @label }
    end
  end

  # GET /labels/1/edit
  def edit
    @label = Label.find(params[:id])
  end

  # POST /labels
  # POST /labels.xml
  def create
    @label = Label.create_record(params, @company.id)
    respond_to do |format|
      if @label.save
        @label.register_user_action(@current_user.id, request.remote_ip, 'created', @current_user.branch_id)
        format.html { redirect_to(@label, :notice => 'Terminology was successfully created.') }
        format.xml  { render :xml => @label, :status => :created, :location => @label }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @label.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /labels/1
  # PUT /labels/1.xml
  def update
    @label = Label.find(params[:id])
    respond_to do |format|
      if @label.update_attributes(params[:label])
        @label.register_user_action(@current_user.id,request.remote_ip, 'updated', @current_user.branch_id)     
        format.html { redirect_to("/labels/show", :notice => 'Terminology was successfully updated.') }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@label) }
      end
    end
  end

  # DELETE /labels/1
  # DELETE /labels/1.xml
  def destroy
    @label = Label.find(params[:id])
    @label.destroy
    @label.register_user_action(@current_user.id, request.remote_ip, 'deleted', @current_user.branch_id)
    respond_to do |format|
      format.html { redirect_to("/labels/show", :notice => "Label has been deleted successfully") }
      format.xml  { head :ok }
    end
  end


  private
  def menu_title
    @menu = "Settings"
    @page_name = "Terminology"
  end
end
