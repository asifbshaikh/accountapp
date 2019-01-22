class WorkstreamsController < ApplicationController
  # GET /workstreams
  # GET /workstreams.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @workstreams }
      format.json { render :json => WorkstreamDatatable.new(view_context, @company, @current_user)}
    end
  end

  # GET /workstreams/1
  # GET /workstreams/1.xml
  def show
    @workstream = Workstream.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @workstream }
    end
  end

  # GET /workstreams/new
  # GET /workstreams/new.xml
  def new
    @workstream = Workstream.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @workstream }
    end
  end

  # GET /workstreams/1/edit
  def edit
    @workstream = Workstream.find(params[:id])
  end

  # POST /workstreams
  # POST /workstreams.xml
  def create
    @workstream = Workstream.new(params[:workstream])

    respond_to do |format|
      if @workstream.save
        format.html { redirect_to(@workstream, :notice => 'Workstream was successfully created.') }
        format.xml  { render :xml => @workstream, :status => :created, :location => @workstream }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @workstream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workstreams/1
  # PUT /workstreams/1.xml
  def update
    @workstream = Workstream.find(params[:id])

    respond_to do |format|
      if @workstream.update_attributes(params[:workstream])
        format.html { redirect_to(@workstream, :notice => 'Workstream was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @workstream.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workstreams/1
  # DELETE /workstreams/1.xml
  def destroy
    @workstream = Workstream.find(params[:id])
    @workstream.destroy

    respond_to do |format|
      format.html { redirect_to(workstreams_url) }
      format.xml  { head :ok }
    end
  end
end
