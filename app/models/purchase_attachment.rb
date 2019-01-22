class PurchaseAttachment < ActiveRecord::Base


	belongs_to :purchases,:foreign_key=>:Purchase_id
    attr_accessor :old_file_size 

	has_attached_file :uploaded_file,
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/purchases/:id/:basename.:extension"
 	
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
 def self.purchase_attachments(params, company, user)
      attachfile = PurchaseAttachment.new(params[:purchase_document])
      attachfile.company_id = company.id
      attachfile.user_id = user.id
      attachfile.purchase_id = params[:purchase_id]
      attachfile
    end

  def storage_limit
    errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, uploaded_file_file_size, old_file_size)
  end
end
