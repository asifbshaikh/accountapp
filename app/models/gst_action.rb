class GstAction < ActiveRecord::Base

	def get_url(gst_return_type,action,version)
		url=GstAction.where(:gst_return_type => gst_return_type,:action =>action,:version => version)
		puts url
		
	end
end
