class GstReturnsController < ApplicationController
  # GET /gst_returns
  # GET /gst_returns.json
  def index
    #determine current month get drop down for last 3 months of data present
    @gst_start_month = 7
    @gst_end_month = @gst_start_month + 2
    @selected_month = params[:month].present? ? params[:month].to_i : @gst_start_month
    @gst_returns = @company.gst_returns.return_month(@selected_month)
    if @gst_returns.blank?
      redirect_to controller: :gst_authorizer, action: :new
    else
      respond_to do |format|
        format.html # index.html.erb
      end
    end  
  end

  # GET /gst_returns/1
  # GET /gst_returns/1.json
  def show
    @gst_return = @company.gst_returns.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gst_return }
    end
  end

  # GET /gst_returns/new
  # GET /gst_returns/new.json
  def new
    @gst_return = GstReturn.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gst_return }
    end
  end

  # GET /gst_returns/1/edit
  def edit
    @gst_return = @company.gst_returns.find(params[:id])
  end

  # POST /gst_returns
  # POST /gst_returns.json
  def create
    @gst_return = GstReturn.new(params[:gst_return])

    respond_to do |format|
      if @gst_return.save
        format.html { redirect_to @gst_return, notice: 'Gst return was successfully created.' }
        format.json { render json: @gst_return, status: :created, location: @gst_return }
      else
        format.html { render action: "new" }
        format.json { render json: @gst_return.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gst_returns/1
  # PUT /gst_returns/1.json
  def update
    @gst_return = @company.gst_returns.find(params[:id])

    respond_to do |format|
      if @gst_return.update_attributes(params[:gst_return])
        format.html { redirect_to @gst_return, notice: 'Gst return was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @gst_return.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gst_returns/1
  # DELETE /gst_returns/1.json
  def destroy
    @gst_return = @company.gst_returns.find(params[:id])
    @gst_return.destroy

    respond_to do |format|
      format.html { redirect_to gst_returns_url }
      format.json { head :ok }
    end
  end
end
