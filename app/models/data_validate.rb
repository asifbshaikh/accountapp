class DataValidate
	class << self
		def parsed_start_date(financial_year, date)
			start_date = nil
			begin 
	      start_date = Date.parse(date)
	    rescue
	      start_date = nil
	    end
	    start_date
		end

		def parsed_end_date(financial_year, date)
			end_date = nil
			begin 
	      end_date = Date.parse(date)
	    rescue
	      end_date = nil
	    end
	    end_date
		end
	end
end