class AuditorAssignment < ActiveRecord::Base
  belongs_to :auditor
  belongs_to :role
end
