class Gstr2a < ActiveRecord::Base
	has_many :gstr2a_items
	has_many :gstr2a_line_items
	belongs_to :company



	STATUS = {open: 0, uploaded: 1, partially_verified:2, verified: 3, final: 4, processing: 5, failed: 6}.with_indifferent_access

	class << self


	def create_return(company, gst_return, due_date)
      attr = {:company_id => company.id, :financial_year_id => company.financial_years.last.id, :month => gst_return.month, :gst_return_id => gst_return.id,:year => Time.now.to_date.year}
      gstr_two = (Gstr2a.find_by_company_id_and_gst_return_id(company.id, gst_return.id) || Gstr2a.create!(attr))
      #GstrTwo.create!(:company_id => company.id, :financial_year_id => company.financial_years.last.id, :month => gst_return.month, :gst_return_id => gst_return.id, :due_date => due_date)
    end

	end

	def failed
    update_attributes(:status => STATUS[:failed])
  end


	def processing
    update_attributes(:status => STATUS[:processing])
  end

     def return_period
    "#{self.month.to_s.rjust(2,'0')}#{self.year}"
  end

  def populate
  end
end

