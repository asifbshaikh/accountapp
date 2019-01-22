class VendorImportsController < ApplicationController
  # GET /vendor_imports
  # GET /vendor_imports.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => VendorImportDatatable.new(view_context,@company)}
    end
  end

  # GET /vendor_imports/1
  # GET /vendor_imports/1.json
  def show
    @vendor_import = VendorImport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @vendor_import }
    end
  end

  # GET /vendor_imports/new
  # GET /vendor_imports/new.json
  def new
    @vendor_import = VendorImport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @vendor_import }
    end
  end

  # GET /vendor_imports/1/edit
  def edit
    @vendor_import = VendorImport.find(params[:id])
  end

  # POST /vendor_imports
  # POST /vendor_imports.json
  def create
    @vendor_import = VendorImport.new(params[:vendor_import])

    respond_to do |format|
      if @vendor_import.save
        format.html { redirect_to @vendor_import, :notice => 'Vendor import was successfully created.' }
        format.json { render :json => @vendor_import, :status => :created, :location => @vendor_import }
      else
        format.html { render :action => "new" }
        format.json { render :json => @vendor_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /vendor_imports/1
  # PUT /vendor_imports/1.json
  def update
    @vendor_import = VendorImport.find(params[:id])

    respond_to do |format|
      if @vendor_import.update_attributes(params[:vendor_import])
        format.html { redirect_to @vendor_import, :notice => 'Vendor import was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @vendor_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /vendor_imports/1
  # DELETE /vendor_imports/1.json
  def destroy
    @vendor_import = VendorImport.find(params[:id])
    @vendor_import.destroy

    respond_to do |format|
      format.html { redirect_to vendor_imports_url }
      format.json { head :ok }
    end
  end
  def upload
    imported_file = ImportFile.new(params[:import_file])
    if imported_file.save
      VendorImport.perform_async(imported_file.id,@company.id,@current_user.id)
      redirect_to("/vendor_imports/preview?file_id=#{imported_file.id}")
    else
      render :action => "index" 
      flash[:error]= "Something went wrong !"
    end
  end

  def preview
    respond_to do |format|
      if request.format=='*/*'
        @import_file=ImportFile.find params[:file_id]
        format.js
      else
        format.html
      end
    end
  end

  def import_preview
    @file_id = params[:file_id]
    @total_row = params[:file_row].to_i
    @imported_vendors = VendorImport.where(:import_file_id => params[:file_id])
    @successfull_vendors = @imported_vendors.where(:status => 1).count
    @failed_vendors = @imported_vendors.where(:status => 0).count
  end

  def delete_file
    @vendor_file = ImportFile.find(params[:id])
    @vendor_file.destroy
    respond_to do |format|
      format.html { redirect_to vendor_imports_url,:notice => "File has been deleted successfully." }
      format.json { head :ok }
    end
  end
end
