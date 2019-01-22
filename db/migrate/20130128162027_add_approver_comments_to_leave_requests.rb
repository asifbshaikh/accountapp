class AddApproverCommentsToLeaveRequests < ActiveRecord::Migration
  def self.up
    add_column :leave_requests, :approver_comment, :string
  end

  def self.down
    remove_column :leave_requests, :approver_comment
  end
end
