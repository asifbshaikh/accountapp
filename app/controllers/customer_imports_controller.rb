class CustomerImportsController < ApplicationController
  # GET /customer_imports
  # GET /customer_imports.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => CustomerImportDatatable.new(view_context,@company)}
    end
  end

  # GET /customer_imports/1
  # GET /customer_imports/1.json
  def show
    @customer_import = CustomerImport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @customer_import }
    end
  end

  # GET /customer_imports/new
  # GET /customer_imports/new.json
  def new
    @customer_import = CustomerImport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @customer_import }
    end
  end

  # GET /customer_imports/1/edit
  def edit
    @customer_import = CustomerImport.find(params[:id])
  end

  # POST /customer_imports
  # POST /customer_imports.json
  def create
    @customer_import = CustomerImport.new(params[:customer_import])

    respond_to do |format|
      if @customer_import.save
        format.html { redirect_to @customer_import, :notice => 'Customer import was successfully created.' }
        format.json { render :json => @customer_import, :status => :created, :location => @customer_import }
      else
        format.html { render :action => "new" }
        format.json { render :json => @customer_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /customer_imports/1
  # PUT /customer_imports/1.json
  def update
    @customer_import = CustomerImport.find(params[:id])

    respond_to do |format|
      if @customer_import.update_attributes(params[:customer_import])
        format.html { redirect_to @customer_import, :notice => 'Customer import was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @customer_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /customer_imports/1
  # DELETE /customer_imports/1.json
  def destroy
    @customer_import = CustomerImport.find(params[:id])
    @customer_import.destroy

    respond_to do |format|
      format.html { redirect_to customer_imports_url }
      format.json { head :ok }
    end
  end

  def upload
    @imported_file = ImportFile.new(params[:import_file])
    if @imported_file.save
      CustomerImportWorker.perform_async(@company.id, @current_user.id, @imported_file.id)
      redirect_to("/customer_imports/preview?file_id=#{@imported_file.id}")
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
    @imported_customers = CustomerImport.where(:import_file_id => params[:file_id])
    @successfull_customers = @imported_customers.where(:status => 1).count
    @failed_customers = @imported_customers.where(:status => 0).count
  end

  def delete_file
    @customer_file = ImportFile.find(params[:id])
    @customer_file.destroy
    respond_to do |format|
      format.html { redirect_to customer_imports_url,:notice => "File has been deleted successfully." }
      format.json { head :ok }
    end
  end
end
