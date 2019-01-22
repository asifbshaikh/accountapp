class LeaveCardsController < ApplicationController
  # layout "payroll"#, :except => [:show]

  # GET /leave_cards
  # GET /leave_cards.xml
  def index
    @users = @company.users
    @leave_cards = @company.leave_cards
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @leave_cards }
    end
  end

  # GET /leave_cards/1
  # GET /leave_cards/1.xml
  def show
    @menu = 'Self Service'
    @page_name = 'Leave Card'
    @user = User.find_by_company_id_and_id(@company.id, params[:user_id])
      @leave_cards = LeaveCard.current_leave_card @user.id
    # @leave_card = LeaveCard.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @leave_card }
    end
  end

  # GET /leave_cards/new
  # GET /leave_cards/new.xml
  def new
    @menu = 'Self Service'
    @page_name = 'Leave Card'

    @leave_card = LeaveCard.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @leave_card }
    end
  end

  # GET /leave_cards/1/edit
  def edit
    @menu = 'Self Service'
    @page_name = 'Leave Card'

    @leave_card = LeaveCard.find(params[:id])
  end

  # POST /leave_cards
  # POST /leave_cards.xml
  def create
    @leave_card = LeaveCard.create_card(params, @company.id)
    @user = @leave_card.user
    @leave_cards = LeaveCard.current_leave_card @leave_card.user_id
    respond_to do |format|
      @leave_card.save
      format.js { render "create_leave_card" }
    end
  end

  # PUT /leave_cards/1
  # PUT /leave_cards/1.xml
  def update
    @leave_card = LeaveCard.find(params[:id])

    respond_to do |format|
      if @leave_card.update_attributes(params[:leave_card])
        format.html { redirect_to(@leave_card, :notice => 'Leave card was successfully updated.') }
        format.xml  { head :ok }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@leave_card) }
        format.xml  { render :xml => @leave_card.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /leave_cards/1
  # DELETE /leave_cards/1.xml
  def destroy
    @leave_card = LeaveCard.find(params[:id])
    @leave_card.destroy unless @leave_card.utilized?

    respond_to do |format|
      format.html { redirect_to("/users/#{@leave_card.user_id}/#leaves") }
      format.xml  { head :ok }
    end
  end
end
