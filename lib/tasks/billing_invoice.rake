namespace :billing_invoices do 
  task :update_closed_by => :environment do 
    ActiveRecord::Base.transaction do 
      naveen_billing_invoices = BillingInvoice.where(:received_by => "Naveen Thota")
      harshal_billing_invoices = BillingInvoice.where(:received_by => "Harshal Katre")
      prasad_billing_invoices = BillingInvoice.where(:received_by => "Prasad Bhoot")
      mohnish_billing_invoices = BillingInvoice.where(:received_by => "Mohnish Katre")
      amit_billing_invoices = BillingInvoice.where(:received_by => "Amit Mahalle")
      sneha_billing_invoices = BillingInvoice.where(:received_by => "Sneha Bharate")
      mohit_billing_invoices = BillingInvoice.where(:received_by => "Mohit Mogha")
      sachin_billing_invoices = BillingInvoice.where(:received_by => "Sachin Kumar")
      blank_billing_invoices = BillingInvoice.where(:received_by => nil)

      naveen_billing_invoices.update_all(:closed_by => 1)
      harshal_billing_invoices.update_all(:closed_by => 2)
      prasad_billing_invoices.update_all(:closed_by => 3)
      mohnish_billing_invoices.update_all(:closed_by => 5)
      amit_billing_invoices.update_all(:closed_by => 7)
      sneha_billing_invoices.update_all(:closed_by => 9)
      mohit_billing_invoices.update_all(:closed_by => 10)
      sachin_billing_invoices.update_all(:closed_by => 11)
      blank_billing_invoices.update_all(:closed_by => 5)

      puts"**************naveen_billing_invoices  #{naveen_billing_invoices.count} updated"
      puts"**************harshal_billing_invoices  #{harshal_billing_invoices.count} updated"
      puts"**************prasad_billing_invoices  #{prasad_billing_invoices.count} updated"
      puts"**************mohnish_billing_invoices  #{mohnish_billing_invoices.count} updated"
      puts"**************amit_billing_invoices  #{amit_billing_invoices.count} updated"
      puts"**************sneha_billing_invoices  #{sneha_billing_invoices.count} updated"
      puts"**************mohit_billing_invoices  #{mohit_billing_invoices.count} updated"
      puts"**************sachin_billing_invoices  #{sachin_billing_invoices.count} updated"
      puts"**************blank_billing_invoices  #{blank_billing_invoices.count} updated"
    end
  end
end