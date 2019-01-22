namespace :address do
  
  #This task should only be run once
  task :update_address => :environment do
     @addresses = Address.find_all_by_addressable_type(["Company", "SundryDebtor"])
     @addresses.each do |address|
       if !address.blank? 
         if address.update_attributes(:address_line1 => "#{address.address_line1+ ',' unless address.address_line1.blank?}\n#{address.address_line2+ ',' unless address.address_line2.blank?}\n #{address.city+',' unless address.city.blank?} #{address.state+',' unless address.state.blank?}\n#{address.country+',' unless address.country.blank?} #{address.postal_code unless address.postal_code.blank?} " )
          puts"@@@ address updated for #{address.addressable_type}"
         else
          puts"@@@ something went wrong for #{address.addressablae_type} address update"
         end
       end
    end
  end
  
end