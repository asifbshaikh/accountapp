class Gstr1SummariesController < ApplicationController
  # GET /gstr1_summaries
  # GET /gstr1_summaries.json
  def index
    @gstr1_summaries = nil

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gstr1_summaries }
    end
  end

  # GET /gstr1_summaries/1
  # GET /gstr1_summaries/1.json
  def show
    @gstr1_summary = Gstr1Summary.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gstr1_summary }
    end
  end

  # GET /gstr1_summaries/new
  # GET /gstr1_summaries/new.json
  def new
    @gstr1_summary = Gstr1Summary.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gstr1_summary }
    end
  end

  def fetch
    @gstr1_summary = @company.gstr1_summaries.find(params[:id])
    session_srv = SessionService.new(@company, nil)
    if session_srv.active_session_present?
      Gstr1SummaryWorker.perform_async(@company.id, request.remote_ip, @gstr1_summary.id)
      respond_to do |format|
        format.html { redirect_to action: 'processing', id: @gstr1_summary.id }
      end
      # redirect_to gstr1_filing_path(@gstr_one), :notice => "GSTR-1 data uploaded successfully"
    else
      redirect_to new_login_request_path(:action_value => @gstr1_summary.id, :action_key => "gstr1_summary")
    end
  end

  # GET /gstr1_summaries/1/edit
  def edit
    @gstr1_summary = Gstr1Summary.find(params[:id])
  end

  # POST /gstr1_summaries
  # POST /gstr1_summaries.json
  def create
    @gstr1_summary = Gstr1Summary.new(params[:gstr1_summary])

    respond_to do |format|
      if @gstr1_summary.save
        format.html { redirect_to @gstr1_summary, notice: 'Gstr1 summary was successfully created.' }
        format.json { render json: @gstr1_summary, status: :created, location: @gstr1_summary }
      else
        format.html { render action: "new" }
        format.json { render json: @gstr1_summary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gstr1_summaries/1
  # PUT /gstr1_summaries/1.json
  def update
    @gstr1_summary = Gstr1Summary.find(params[:id])

    respond_to do |format|
      if @gstr1_summary.update_attributes(params[:gstr1_summary])
        format.html { redirect_to @gstr1_summary, notice: 'Gstr1 summary was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @gstr1_summary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gstr1_summaries/1
  # DELETE /gstr1_summaries/1.json
  def destroy
    @gstr1_summary = Gstr1Summary.find(params[:id])
    @gstr1_summary.destroy

    respond_to do |format|
      format.html { redirect_to gstr1_summaries_url }
      format.json { head :ok }
    end
  end

  #[FIXME] Naveen - I have introduced a new status called processing as long as it is in that status
  # this page should be shown else redirect to index page
  def processing
    @gstr1_summary = @company.gstr1_summaries.find(params[:id])
    @gstr1_summary_processing_check = @gstr1_summary.processing?
    respond_to do |format|
      if request.format== '*/*'
        format.js
      else
        format.html
      end
    end
  end


end
