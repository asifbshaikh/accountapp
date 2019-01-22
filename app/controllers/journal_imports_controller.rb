class JournalImportsController < ApplicationController
  require 'date'
  require 'csv'
  require 'open-uri'
  # GET /journal_imports
  # GET /journal_imports.json
  def index
    @journal_imports = JournalImport.all

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render :json => @journal_imports }
      format.json { render :json => JournalImportDatatable.new(view_context,@company)}
    end
  end

  # GET /journal_imports/1
  # GET /journal_imports/1.json
  def show
    @journal_import = JournalImport.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @journal_import }
    end
  end

  # GET /journal_imports/new
  # GET /journal_imports/new.json
  def new
    @journal_import = JournalImport.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @journal_import }
    end
  end

  # GET /journal_imports/1/edit
  def edit
    @journal_import = JournalImport.find(params[:id])
  end

  # POST /journal_imports
  # POST /journal_imports.json
  def create
    @journal_import = JournalImport.new(params[:journal_import])

    respond_to do |format|
      if @journal_import.save
        format.html { redirect_to @journal_import, :notice => 'Journal import was successfully created.' }
        format.json { render :json => @journal_import, :status => :created, :location => @journal_import }
      else
        format.html { render :action => "new" }
        format.json { render :json => @journal_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /journal_imports/1
  # PUT /journal_imports/1.json
  def update
    @journal_import = JournalImport.find(params[:id])

    respond_to do |format|
      if @journal_import.update_attributes(params[:journal_import])
        format.html { redirect_to @journal_import, :notice => 'Journal import was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @journal_import.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /journal_imports/1
  # DELETE /journal_imports/1.json
  def destroy
    @journal_import = JournalImport.find(params[:id])
    @journal_import.destroy

    respond_to do |format|
      format.html { redirect_to journal_imports_url }
      format.json { head :ok }
    end
  end

  def upload
    imported_file = ImportFile.new(params[:import_file])
    if imported_file.save
      JournalImport.perform_async(imported_file.id,@company.id,@current_user.id, @financial_year.year.name)
      redirect_to("/journal_imports/preview?file_id=#{imported_file.id}")
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
    @imported_journals = JournalImport.where(:import_file_id => params[:file_id])
    @successfull_journals = @imported_journals.where(:status => 1).count
    @failed_journals = @imported_journals.where(:status => 0).count
  end

  def delete_file
    @journal_file = ImportFile.find(params[:id])
    @journal_file.destroy
    respond_to do |format|
      format.html { redirect_to journal_imports_url,:notice => "File has been deleted successfully." }
      format.json { head :ok }
    end
  end
end
