class PayGradesController < ApplicationController
  # GET /pay_grades
  # GET /pay_grades.xml
  def index
    @users = User.users_in_company(session[:userid])
    @pay_grades = PayGrade.all
    @pay_grade = PayGrade.new

    respond_to do |format|
      format.html # index.html.erb
      format.html # new.html.erb
      format.xml  { render :xml => @pay_grades }
    end
  end

  # GET /pay_grades/1
  # GET /pay_grades/1.xml
  def show
    @pay_grade = PayGrade.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pay_grade }
    end
  end

  

  # GET /pay_grades/1/edit
  def edit
   @users = User.users_in_company(session[:userid])
    @pay_grade = PayGrade.find(params[:id])
  end

  # POST /pay_grades
  # POST /pay_grades.xml
  def create
    @pay_grade = PayGrade.new(params[:pay_grade])
    @pay_grade.user_id = session[:userid]
    respond_to do |format|
      if @pay_grade.save
        @pay_grades = PayGrade.all
        @pay_grade = PayGrade.new
        format.html { redirect_to pay_grades_path }
        
        format.xml  { render :xml => @pay_grade, :status => :created, :location => @pay_grade }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pay_grade.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pay_grades/1
  # PUT /pay_grades/1.xml
  def update
    @pay_grade = PayGrade.find(params[:id])

    respond_to do |format|
      if @pay_grade.update_attributes(params[:pay_grade])
        format.html { redirect_to(@pay_grade, :notice => 'Pay grade was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pay_grade.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pay_grades/1
  # DELETE /pay_grades/1.xml
  def destroy
    @pay_grade = PayGrade.find(params[:id])
    @pay_grade.destroy

    respond_to do |format|
      format.html { redirect_to(pay_grades_url) }
      format.xml  { head :ok }
    end
  end
end
