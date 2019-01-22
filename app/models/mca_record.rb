class McaRecord < ActiveRecord::Base

  STATUS = {'1' => "MCA Record", '2' => "Maha Tech"}

	def self.get_records(month)
		logger.info"**********#{month}"
		abc = self.where(:month => month).count
		abc
	end
end
