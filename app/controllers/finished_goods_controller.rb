class FinishedGoodsController < ApplicationController
  layout "application", :except => [:show]
  # GET /finished_goods
  # GET /finished_goods.xml
  def index
    @finished_goods = FinishedGood.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @finished_goods }
    end
  end

  # GET /finished_goods/1
  # GET /finished_goods/1.xml
  def show
    @finished_good = FinishedGood.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @finished_good }
    end
  end

  # GET /finished_goods/new
  # GET /finished_goods/new.xml
  def new
    @finished_good = FinishedGood.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @finished_good }
    end
  end

  # GET /finished_goods/1/edit
  def edit
    @finished_good = FinishedGood.find(params[:id])
  end

  # POST /finished_goods
  # POST /finished_goods.xml
  def create
    @finished_good = FinishedGood.new(params[:finished_good])

    respond_to do |format|
      if @finished_good.save
        format.html { redirect_to(@finished_good, :notice => 'Finished good was successfully created.') }
        format.xml  { render :xml => @finished_good, :status => :created, :location => @finished_good }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @finished_good.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /finished_goods/1
  # PUT /finished_goods/1.xml
  def update
    @finished_good = FinishedGood.find(params[:id])

    respond_to do |format|
      if @finished_good.update_attributes(params[:finished_good])
        format.html { redirect_to(@finished_good, :notice => 'Finished good was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @finished_good.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /finished_goods/1
  # DELETE /finished_goods/1.xml
  def destroy
    @finished_good = FinishedGood.find(params[:id])
    @finished_good.destroy

    respond_to do |format|
      format.html { redirect_to(finished_goods_url) }
      format.xml  { head :ok }
    end
  end
end
