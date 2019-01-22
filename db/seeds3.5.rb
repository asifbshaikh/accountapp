ActiveRecord::Base.transaction do
	# Seed for converting free plan to PayWhatYouWant
	#Rename plan name 
	free_plan = Plan.find_by_name('free')
	free_plan.update_attributes(:name=>"PWYW", :display_name=>"Pay what you want", :price=>1)
end