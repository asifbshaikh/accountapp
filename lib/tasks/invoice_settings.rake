
namespace :invoice do
  task :reset_daily_sequence => :environment do
    # update all invoice_sequence = 0 where invoice_no_strategy=2
    InvoiceSetting.update_all(:invoice_sequence =>0, :invoice_no_strategy => InvoiceSetting::INVOICE_NUMBERING_STRATEGY[:daily_reset_sequence_with_date])
  end

  #this task will create entries for all existing companies in the newly created invoice_settings table with default value of random generation
  #This task should only be run once
  task :initial_entries => :environment do
    @companies = Company.all
    @companies.each do |company|
      InvoiceSetting.create(:company_id => company.id, :invoice_sequence => 0, :invoice_no_strategy => InvoiceSetting::INVOICE_NUMBERING_STRATEGY[:random_number],
            :invoice_prefix => 'INV')
    end
  end
  
end