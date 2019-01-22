class Myfile < ActiveRecord::Base
  # after_save :utilized_storage
  attr_accessor :old_file_size
  attr_accessible :user_id, :uploaded_file, :folder_id
  
  #relationships
  belongs_to :user
  belongs_to :folder
  
  #set up "uploaded_file" field as attached_file (using Paperclip)  
  has_attached_file :uploaded_file, 
                    :storage=>:s3,
                    :s3_credentials=>"#{Rails.root}/config/s3.yml",
                    :url => ":s3_domain_url",
                    :path => "/uploaded_data/:class/:id/:basename.:extension"
  
  #validations 
  validates_attachment_size :uploaded_file, :less_than => 12.megabytes     
  validates_attachment_presence :uploaded_file
  validate :storage_limit  
  def file_name  
    uploaded_file_file_name  
  end  
   def file_size  
    uploaded_file_file_size  
  end 
  # def utilized_storage
  #      subscription = Subscription.find_by_status_id_and_company_id(1, company_id)
  #      logger.info "@@@22 old file size is #{old_file_size} and current file size is #{uploaded_file_file_size}"
  #      subscription.increase_storage(uploaded_file_file_size, old_file_size)
  # end
  def self.upload_file(params, company, user)
      myfile = Myfile.new(params[:myfile])
      myfile.company_id = company.id
      myfile.user_id = user.id
      myfile.old_file_size = 0
      myfile
    end

   def self.cashfree_file(params, company, user)

      myfiles = Myfile.new(params[:myfile])
      myfiles.company_id = company.id
      myfiles.user_id = user.id
      myfiles.old_file_size = 0
      myfiles
    end
  
   def register_user_action(remote_ip, action, branch_id)
     Subscription.increase_storage(company_id, uploaded_file_file_size, old_file_size)
     Workstream.register_user_action(company_id, user_id, remote_ip,
     " A file #{uploaded_file_file_name} #{action}.", action, branch_id)
   end
 private
 
  def storage_limit
    errors[:base] << "Storage limit reached, your plan does not allow storing any more files." if Subscription.storage_limit?(company_id, uploaded_file_file_size, old_file_size)
  end
end
