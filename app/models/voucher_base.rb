module VoucherBase
	module ClassMethods
		
	end
	
	module InstanceMethods
		def add_tax_line(line)
			# logger.info"+++++++ self.class: #{self.class}"
		  unless line.marked_for_destruction?
		    line.send("#{self.class.to_s.underscore}_taxes").each do |tax|
		      account = tax.account
		      unless account.blank? || (line.has_attribute?(:quantity) && line.quantity.blank?) || (line.has_attribute?(:unit_rate) && line.unit_rate.blank?)
		        tax_lines=account.add_tax_lines(self, line)
		        tax_lines.each { |tax_line| self.tax_line_items<<tax_line}
		      end
		    end
		  end
		end

		def build_tax
		  send("#{self.class.to_s.underscore}_line_items").each do |line|
		    add_tax_line(line)
		  end
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end