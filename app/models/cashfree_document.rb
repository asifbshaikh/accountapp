class CashfreeDocument < ActiveRecord::Base
belongs_to :user
  belongs_to :folder
  attr_accessible  :uploaded_file_one,:uploaded_file_two,:uploaded_file_three,:company_id, :created_by,:id,:name,:pan
  #set up "uploaded_file" field as attached_file (using Paperclip)  
  has_attached_file :uploaded_file_one, 
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:company_id/:basename.:extension"

   has_attached_file :uploaded_file_two, 
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:company_id/:basename.:extension"
   has_attached_file :uploaded_file_three, 
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:company_id/:basename.:extension"

  validates_attachment_content_type :uploaded_file_one, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true

  validates_attachment_content_type :uploaded_file_two, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true

  validates_attachment_content_type :uploaded_file_three, :content_type => ['image/jpeg','image/png','image /jpg','image/gif', 'application/pdf'],
                                    :message=>" must be of .jpeg,'.jpg', '.gif', .png or .pdf type",
                                    :allow_nil => true
  
  #validations 
  validates_attachment_size :uploaded_file_one, :less_than => 1.megabytes    
  validates_attachment_presence :uploaded_file_one
  validates_attachment_size :uploaded_file_two, :less_than => 1.megabytes
  validates_attachment_presence :uploaded_file_two
  validates_attachment_size :uploaded_file_three, :less_than => 1.megabytes
  validates_attachment_presence :uploaded_file_three

	  def self.cashfree_file(params, company, user)

      myfiles = CashfreeDocument.new(params[:cashfree_document])
      logger.debug myfiles.inspect
      myfiles.pan= params[:pan]
      myfiles.company_id = company.id
      myfiles.created_by = user.id  
      myfiles
    end
end
