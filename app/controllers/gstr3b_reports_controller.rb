class Gstr3bReportsController < ApplicationController
  # GET /gstr3b_reports
  # GET /gstr3b_reports.json
  def index
    @gstr3b_reports = @company.gstr3b_reports
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gstr3b_reports }
    end
  end

  # GET /gstr3b_reports/1
  # GET /gstr3b_reports/1.json
  def show
    @gstr3b_report = @company.gstr3b_reports.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gstr3b_report }
      format.pdf do
        pdf=Gstr3bReportPdf.new(view_context, @company, @gstr3b_report)
        send_data pdf.render, :filename=>"GSTR_3B_#{@gstr3b_report.month_name}.pdf", :disposition=>"inline", :type=>'application/pdf'
      end
    end
  end

  # GET /gstr3b_reports/new
  # GET /gstr3b_reports/new.json
  def new
    @gstr3b_report = Gstr3bReport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gstr3b_report }
    end
  end

  # GET /gstr3b_reports/1/edit
  def edit
    @gstr3b_report = @company.gstr3b_reports.find(params[:id])
    @section3 = @gstr3b_report.generate_section3
    @section32 = @section3.section32
    @section4 = @gstr3b_report.generate_section4
    @section5 = @gstr3b_report.generate_section5
    @section6 = @gstr3b_report.generate_section61
    #@gstr3b_report_srvc = Gstr3bReportService.new(@company, @current_user, @gstr3b_report.month, @financial_year, @gstr3b_report)
    #@gstr3b_report_srvc.generate_report
  end

  # POST /gstr3b_reports
  # POST /gstr3b_reports.json
  def create
    @gstr3b_report = Gstr3bReport.new(params[:gstr3b_report])

    respond_to do |format|
      if @gstr3b_report.save
        format.html { redirect_to @gstr3b_report, notice: 'Gstr3b report was successfully created.' }
        format.json { render json: @gstr3b_report, status: :created, location: @gstr3b_report }
      else
        format.html { render action: "new" }
        format.json { render json: @gstr3b_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gstr3b_reports/1
  # PUT /gstr3b_reports/1.json
  def update
    @gstr3b_report = Gstr3bReport.find(params[:id])

    respond_to do |format|
      if @gstr3b_report.update_attributes(params[:gstr3b_report])
        format.html { redirect_to @gstr3b_report, notice: 'Gstr3b report was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @gstr3b_report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gstr3b_reports/1
  # DELETE /gstr3b_reports/1.json
  def destroy
    @gstr3b_report = Gstr3bReport.find(params[:id])
    @gstr3b_report.destroy

    respond_to do |format|
      format.html { redirect_to gstr3b_reports_url }
      format.json { head :ok }
    end
  end
end
