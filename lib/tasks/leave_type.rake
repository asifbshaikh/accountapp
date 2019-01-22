namespace :leave_type do
	desc "To updated newly added column 'paid' to false"
	task :mark_unpaid => :environment do
		LeaveType.update_all(:paid=>false)
	end
end