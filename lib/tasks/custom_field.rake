namespace :custom_field do

  task :create_field => :environment do
    @companies = Company.all
    @companies.each do |company|
      if company.plan.free_plan?
        voucher_types = ["Invoice","StockIssueVoucher", "StockReceiptVoucher","StockWastageVoucher","Estimate","Purchase"]
        voucher_types.each do |voucher_type|
          custom_filed = CustomField.find_by_company_id_and_voucher_type(company.id, voucher_type)
          if custom_filed.blank?
           CustomField.create(:company_id => company.id, :voucher_type=> voucher_type, :status=> false)
           puts "@@@  custom field created for #{voucher_type} voucher for #{company.name}"
          else
             puts "@@@ #{company.name} already has custom field for #{voucher_type}"
          end
        end
      end
    end
  end
  
end