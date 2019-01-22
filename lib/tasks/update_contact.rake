namespace :update_contact do

  task :create_contact => :environment do
    @companies = Company.all
    @companies.each do |company|
     ActiveRecord::Base.transaction do
      @accounts = Account.get_customer_accounts(company.id)
      @accounts.each do |account|
        sundry_debtor = account.accountable
        if !sundry_debtor.blank? && sundry_debtor.contacts.blank?
          Contact.create(:company_id => company.id, :created_by => company.users.first.id, :sundry_debtor_id=> sundry_debtor.id)
          puts"@@@ one contact created for this #{account.name}"
        else
          puts"@@@ #{account.name} already has contact"
        end
      end
    end
    end
  end

end