class SalaryStructureHistoriesController < ApplicationController
# before_filter :menu_title
  # layout "payroll"
  
  def index
    @salary_structure_histories = SalaryStructureHistory.where(:company_id => @company.id, :for_employee=> params[:user_id]).order("created_at DESC").page(params[:page]).per(20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @salary_structure_histories }
    end
  end

  
  def show
    @salary_structure_history = SalaryStructureHistory.find(params[:id])
    @salary_structure_history_line_items = @salary_structure_history.salary_structure_history_line_items
    @currency = @company.currency_code
    respond_to do |format|
      format.html # show.html.erb
      format.pdf {render :layout => false}
      prawnto :filename => "salary_structure_history.pdf"
      format.xml  { render :xml => @salary_structure_history }
    end
  end

  
  def menu_title
   @menu = "Payroll"
   @page_name = "Salary Structure History"
  end

end
