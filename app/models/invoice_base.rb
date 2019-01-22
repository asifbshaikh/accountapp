module InvoiceBase
	module ClassMethods
		
	end
	
	module InstanceMethods
		def get_product(tax_id)
			# TODO:need to change; every time showing first product in taxation report
		  caccount = Account.find_by_id(tax_id)
		  paccount = Account.find_by_id(caccount.parent_id)
		  if self.class.to_s=="Invoice" && time_invoice?
		  	line = time_line_items.includes("#{self.class.to_s.underscore}_taxes".to_sym).where("#{self.class.to_s.underscore}_taxes".to_sym => {:account_id => paccount.blank? ? caccount.id : paccount.id}).first
		  else
		  	line = send("#{self.class.to_s.underscore}_line_items").includes("#{self.class.to_s.underscore}_taxes".to_sym).where("#{self.class.to_s.underscore}_taxes".to_sym =>{ :account_id => paccount.blank? ? caccount.id : paccount.id} ).first
		  end
		  line.product
		end

		def foreign_currency?
		  !currency_id.blank? && !exchange_rate.blank? && exchange_rate != 0 && company.currency_code != currency
		end

		def currency
		  if currency_id.blank?
		    company.currency_code
		  else
		    Currency.find(currency_id).currency_code
		  end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end