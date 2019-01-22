#rake task to create branches
namespace :states do 
  task :create_India_states => :environment do 
    ActiveRecord::Base.transaction do 
      country_id = 93
      states_array = [
        {code: 'AP', name: 'Andhra Pradesh', t: 'S', state_code: 37, capital: 'Amaravati'},
        {code: 'AR', name: 'Arunachal Pradesh', t: 'S', state_code: 12, capital: 'Itanagar'},
        {code: 'AS', name: 'Assam', t: 'S', state_code: 18, capital: 'Dispur'},
        {code: 'BR', name: 'Bihar', t: 'S', state_code: 10, capital: 'Patna'},
        {code: 'CT', name: 'Chhattisgarh', t: 'S', state_code: 22 , capital: 'Raipur'},
        {code: 'GA', name: 'Goa', t: 'S', state_code: 30, capital: 'Panji'},
        {code: 'GJ', name: 'Gujarat', t: 'S', state_code: 24, capital: 'Gandhinagar'},
        {code: 'HR', name: 'Haryana', t: 'S', state_code: 6, capital: 'Chandigarh'},
        {code: 'HP', name: 'Himachal Pradesh', t: 'S', state_code: 2, capital: 'Shimla'},
        {code: 'JK', name: 'Jammu and Kashmir', t: 'S', state_code: 1, capital: 'Shrinagar/Jammu'},
        {code: 'JH', name: 'Jharkand', t: 'S', state_code: 20, capital: 'Ranchi'},
        {code: 'KA', name: 'Karnataka', t: 'S', state_code: 29, capital: 'Bangalore'},
        {code: 'KL', name: 'Kerala', t: 'S', state_code: 32, capital: 'Thiruvananathapuram'},
        {code: 'MP', name: 'Madhya Pradesh', t: 'S', state_code: 23, capital: 'Bhopal'},
        {code: 'MH', name: 'Maharastra', t: 'S', state_code: 27, capital: 'Mumbai'},
        {code: 'MN', name: 'Manipur', t: 'S', state_code: 14, capital: 'Imphal'},
        {code: 'ML', name: 'Meghalaya', t: 'S', state_code: 17, capital: 'Shillong'},
        {code: 'MZ', name: 'Mizoram', t: 'S', state_code: 15, capital: 'Aizwal'},
        {code: 'NL', name: 'Nagaland', t: 'S', state_code: 13, capital: 'Kohima'},
        {code: 'OR', name: 'Odisha', t: 'S', state_code: 21, capital: 'Bubneshwar'},
        {code: 'PB', name: 'Punjab', t: 'S', state_code: 3, capital: 'Chandigarh'},
        {code: 'RJ', name: 'Rajasthan', t: 'S', state_code: 8, capital: 'Jaipur'},
        {code: 'SK', name: 'Sikkim', t: 'S', state_code: 11, capital: 'Gangtok'},
        {code: 'TN', name: 'Tamil Nadu', t: 'S', state_code: 33, capital: 'Chennai'},
        {code: 'TG', name: 'Telangana', t: 'S', state_code: 36, capital: 'Hyderabad'},
        {code: 'TR', name: 'Tripura', t: 'S', state_code: 16, capital: 'Agartala'},
        {code: 'UT', name: 'Uttarakhand', t: 'S', state_code: 5, capital: 'Dehradun'},
        {code: 'UP', name: 'Uttar Pradesh', t: 'S', state_code: 9, capital: 'Lucknow'},
        {code: 'WB', name: 'West Bengal', t: 'S', state_code: 19, capital: 'Kolkatta'},
        {code: 'AN', name: 'Andaman and Nicobar Islands', t: 'UT', state_code: 35, capital: 'Port Blair'},
        {code: 'CH', name: 'Chandigarh', t: 'UT', state_code: 4, capital: 'Chandigarh'},
        {code: 'DN', name: 'Dadra and Nagar Haveli', t: 'UT', state_code: 26, capital: 'Silvassa'},
        {code: 'DD', name: 'Daman and Diu', t: 'UT', state_code: 25, capital: 'Daman'},
        {code: 'DL', name: 'Delhi', t: 'UT', state_code: 7, capital: 'Delhi'},
        {code: 'LD', name: 'Lakshadweep', t: 'UT', state_code: 31, capital: 'Kavaratti'},
        {code: 'PY', name: 'Puducherry', t: 'UT', state_code: 34, capital: 'Puducherry'}
      ]
      states_array.each do |state|
        puts "state is #{state.inspect}"
        state_entry = State.new(code: state[:code], country_id: 93, name: state[:name], state_code: state[:state_code], capital: state[:capital], state_type: state[:state_type])
        state_entry.state_type = state[:t]
        puts "state entry is #{state_entry.inspect}"
        state_entry.save!
      end             
    end
  end

  task :create_Pakistan_states => :environment do 
    ActiveRecord::Base.transaction do 
      country_id = 154
      states_array = [
        {code: 'PJ', name: 'Punjab', t: 'P',  capital: ''},
        {code: 'SN', name: 'Sindh', t: 'P', capital: 'Itanagar'},
        {code: 'KPK', name: 'Khyber Pakhtunkhwa & FATA', t: 'P', capital: 'Dispur'},
        {code: 'BL', name: 'Balochistan', t: 'P', capital: 'Patna'},
        {code: 'GB', name: 'Gilgit-Baltistan', t: 'P', capital: 'Raipur'}
      ]
      states_array.each do |state|
        puts "state is #{state.inspect}"
        state_entry = State.new(code: state[:code], country_id: country_id, name: state[:name], state_code: state[:state_code], capital: state[:capital], state_type: state[:state_type])
        state_entry.state_type = state[:t]
        puts "state entry is #{state_entry.inspect}"
        state_entry.save!
      end             
    end
  end

end    
