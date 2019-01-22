class ImportFile < ActiveRecord::Base
  has_many :product_imports,:dependent => :destroy
  has_many :journal_imports,:dependent => :destroy
  has_many :customer_imports,:dependent => :destroy
  has_many :vendor_imports,:dependent => :destroy
  has_attached_file :file,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:basename.:extension"

  validates_attachment_content_type :file, :content_type => ['text/csv','application/vnd.ms-excel'], 
                                  :message=>" must be of .csv type",
                                  :allow_nil => true
  validates_attachment_presence :file
  # attr_accessible :status
  ITEM_TYPE = {1 => "Products",2 => "Journals",3 => "Customers",4 => "Vendors"}
  STATUS = {0 => "Processing", 1 => "Completed", 2 => "Failed"}
  PROCESSING_STATUS = {in_progress: 0, completed: 1, failed: 2}

  class << self
    def self.read_file(imported_file)
      file_row = 0
      imported_file.drop(1).each do |row|
        file_row += 1
      end
      file_row
    end
  end
  
  def processing_completed
    self.status = PROCESSING_STATUS[:completed]
    save
  end

  def processing_failed
    self.status = PROCESSING_STATUS[:failed]
    save
  end

  def processing_in_progress
    self.status = PROCESSING_STATUS[:in_progress]
    save
  end

end
