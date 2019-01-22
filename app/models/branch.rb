class Branch < ActiveRecord::Base
  belongs_to :company
  has_one :address, :as => :addressable, :dependent => :destroy
  has_many :users

  accepts_nested_attributes_for :address, :allow_destroy => true 

  #validations
  validates_presence_of :name, :message => "of branch is mandatory."

def created_by_user
  User.find(created_by).full_name unless created_by.blank?  
end

def self.list(id)
  branches = Branch.where(:company_id=> id)
    branch_arr=[]
    branches.each do |branch|
      list=[]
      list<<branch.id
      list<<branch.name
      branch_arr<<list
    end
    branch_arr
  end

end
