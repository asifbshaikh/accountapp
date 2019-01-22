class ProductImportsController < ApplicationController
  require 'date'
  require 'csv'
  require 'open-uri'
  # GET /product_imports
  # GET /product_imports.json
  def index
    # @product_imports = ImportFile.where(:company_id => @company.id, :item_type => 1).order("created_at DESC")
    respond_to do |format|
      format.html # index.html.erb
      # format.json { render :json => @product_imports }
      format.json { render :json => ProductImportDatatable.new(view_context,@company)}
    end
  end

  # GET /product_imports/1
  # GET /product_imports/1.json
  def show
    @product_import = ProductImport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @product_import }
    end
  end

  # GET /product_imports/new
  # GET /product_imports/new.json
  def new
    @product_import = ProductImport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @product_import }
    end
  end

  # GET /product_imports/1/edit
  def edit
    @product_import = ProductImport.find(params[:id])
  end

  # POST /product_imports
  # POST /product_imports.json
  def create
  end

  def upload
    imported_file = ImportFile.new(params[:import_file])
    if imported_file.save
      ProductImport.perform_async(imported_file.id, @company.id, @current_user.id)
      redirect_to("/product_imports/preview?file_id=#{imported_file.id}")
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
  # PUT /product_imports/1
  # PUT /product_imports/1.json
  def update
    @product_import = ProductImport.find(params[:id])

    respond_to do |format|
      if @product_import.update_attributes(params[:product_import])
        format.html { redirect_to @product_import, :notice => 'Product import was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @product_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /product_imports/1
  # DELETE /product_imports/1.json
  def destroy
    @product_import = ProductImport.find(params[:id])
    @product_import.destroy

    respond_to do |format|
      format.html { redirect_to product_imports_url }
      format.json { head :ok }
    end
  end
  def delete_file
    @product_file = ImportFile.find(params[:id])
    @product_file.destroy
    respond_to do |format|
      format.html { redirect_to product_imports_url,:notice => "File has been deleted successfully." }
      format.json { head :ok }
    end
  end

  def check_file_status
    imported_file = ImportFile.find(params[:file_id])
    # respond_to do |format|
      if imported_file.status == 1
      redirect_to(:action => "import_preview", :file_id => imported_file.id)
      elsif imported_file.status == 0
        redirect_to("/product_imports/preview?file_id=#{imported_file.id}")
      end
    # end
  end

  def import_preview
    @file_id = params[:file_id]
    @total_row = params[:file_row].to_i
    @imported_products = ProductImport.where(:import_file_id => params[:file_id])
    @successfull_products = @imported_products.where(:status => 1).count
    @failed_products = @imported_products.where(:status => 0).count
    @duplicate_products = @imported_products.where(:status => 2).count
  end
end
