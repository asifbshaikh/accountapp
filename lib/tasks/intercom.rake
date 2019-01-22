namespace :intercom do
  task :create_create => :environment do
    ActiveRecord::Base.transaction do
      user = Intercom::User.create(:email => "darshan.parekh.2006@gmail.com",
                :user_id => "10",
                :name => "Darshan Parekh",
                :created_at =>"25-06-2012",
                :custom_data => {:username => "darshan", 
                    :company=> "Rohit Constructions",
                    :plan => "Free"
                  },
                :last_seen_ip => "127.0.0.1",
                :last_seen_user_agent => "ie8"
              )
    end
  end
end