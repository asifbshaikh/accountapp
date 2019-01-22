class Department < ActiveRecord::Base
  belongs_to :company
  has_many :users
  has_many :master_objectives
   #validation start
  
   validates_presence_of :name,  :status
   validates_uniqueness_of :name, :scope => :company_id

   #code for csv import
  #   def self.csv_header
  #   "company_id,user_id,name,description,status".split(',')
  # end
  
  # def self.build_from_csv(row)
  #   # find existing customer from email or create new
  #   dept = find_or_initialize_by_name(row[2])
  #   dept.attributes ={:company_id => row[0],
  #     :user_id => row[1],
  #     :name => row[2],
  #     :description => row[3],
  #     :status => row[4]}
      
  #   return dept
  # end
  
  # def to_csv
  #   [company_id, user_id, name, description, status]
  # end
end
