ActiveRecord::Base.transaction do
  @companies = Company.all
     @companies.each do |company|
        voucher_setting = VoucherSetting.new
        voucher_setting.voucher_number_strategy = 1
        voucher_setting.company_id = company.id
        voucher_setting.voucher_Type = 27
        voucher_setting.save!
      end
      puts "#{company.name}"
     end
end
