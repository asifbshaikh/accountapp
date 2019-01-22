class InvoiceAttachment < ActiveRecord::Base
 
	belongs_to :invoices,:foreign_key=>:Invoice_id
    attr_accessor :old_file_size 

	has_attached_file :uploaded_file,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/invoices/:id/:basename.:extension"
 	
    validate :storage_limit  
    validates_attachment_size :uploaded_file, :less_than => 5.megabytes
    validates_attachment_presence :uploaded_file
    validates_attachment_content_type :uploaded_file, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true
   def file_name  
    uploaded_file_file_name  
  end  
  
  def file_size  
    uploaded_file_file_size  
  end 
 def self.invoice_attachments(params, company, user)
      attachfile = InvoiceAttachment.new(params[:invoice_document])
      attachfile.company_id = company.id
      attachfile.created_by = user.id
      attachfile.invoice_id = params[:invoice_id]
      attachfile
    end

  def storage_limit
    errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, uploaded_file_file_size, old_file_size)
  end
end
