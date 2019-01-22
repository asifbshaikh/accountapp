class GstAuthorizerController < ApplicationController
  def new
    @gst_categories = GstCategory.all
  end

  def create
    gst_category_id = params[:gst_category_id]
    gstin = params[:GSTIN]
    gstn_username = params[:gstn_username]
  
    respond_to do |format|  
      #first update company with details
      if @company.update_attributes(gst_category_id: gst_category_id, GSTIN: gstin, gstn_username: gstn_username)
        if gstn_username.present? && gstin.present?
          #process report creation in the background through Worker
          GstReportGenerationWorker.perform_async(@company.id)
        end
        format.html { redirect_to({action: :show}, :notice => 'GST details was successfully created.') }  
      else
        format.html { render :action => "new" }
      end
    end  
  end

  def show
  end

end
