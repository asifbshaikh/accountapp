class ReceiptAdvancesController < ApplicationController
  # GET /receipt_advances
  # GET /receipt_advances.json
  def index
    @receipt_advances = ReceiptAdvance.all

    respond_to do |format|
      format.html #index.html.erb
      format.json   { render :json => ReceiptAdvanceDatatable.new(view_context, @company, @current_user, @financial_year) }
    end
  end

  # GET /receipt_advances/1
  # GET /receipt_advances/1.json
  def show
    @receipt_advance = ReceiptAdvance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @receipt_advance }
    end
  end

  # GET /receipt_advances/new
  # GET /receipt_advances/new.json
  def new
    @receipt_advance = ReceiptAdvance.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @receipt_advance }
    end
  end

  # GET /receipt_advances/1/edit
  def edit
    @receipt_advance = ReceiptAdvance.find(params[:id])
  end

  # POST /receipt_advances
  # POST /receipt_advances.json
  def create
    @receipt_advance = ReceiptAdvance.new(params[:receipt_advance])

    respond_to do |format|
      if @receipt_advance.save
        format.html { redirect_to @receipt_advance, notice: 'Receipt advance was successfully created.' }
        format.json { render json: @receipt_advance, status: :created, location: @receipt_advance }
      else
        format.html { render action: "new" }
        format.json { render json: @receipt_advance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /receipt_advances/1
  # PUT /receipt_advances/1.json
  def update
    @receipt_advance = ReceiptAdvance.find(params[:id])

    respond_to do |format|
      if @receipt_advance.update_attributes(params[:receipt_advance])
        format.html { redirect_to @receipt_advance, notice: 'Receipt advance was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @receipt_advance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipt_advances/1
  # DELETE /receipt_advances/1.json

  

  def destroy
    @receipt_advance = ReceiptAdvance.find(params[:id])
    @receipt_advance.destroy

    respond_to do |format|
      format.html { redirect_to receipt_advances_url }
      format.json { head :ok }
    end
  end
end
