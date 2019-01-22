namespace :tax do 
  task :convert => :environment do 
    ActiveRecord::Base.transaction do 
      Rails.logger.info "*** Taxes are being converted ..... "
      puts "*** Taxes are being converted ..... "
      fin_year = "FY14"
      tax_accounts = Account.where(:accountable_type => "DutiesAndTaxesAccounts")
      nil_rate_deleted = 0
      zero_rate_deleted = 0
      invalid_subscriptions = 0
      expired_subscriptions = 0
      converted = 0
      discount_lines = PurchaseLineItem.where(:type => "DiscountLineItem")
      discount_lines.each do |line|
        purchase = line.purchase
        purchase.destroy
      end
      tax_accounts.each do |account|
        company = account.company
        user = company.users.first
        puts"Account details for #{account.name}(#{account.id}) in #{company.name}(#{company.id})"
        invoice_lines = InvoiceLineItem.where(:account_id => account.id, :type => nil)
        estimate_lines = EstimateLineItem.where(:account_id => account.id, :type => nil)
        purchase_lines = PurchaseLineItem.where(:account_id => account.id, :type => nil)
        purchase_order_lines = PurchaseOrderLineItem.where(:account_id => account.id, :type => nil)
        journals = Journal.where(:account_id => account.id)
        journal_lines = JournalLineItem.where(:from_account_id => account.id)
        debit_notes = DebitNote.where(:to_account_id => account.id)
        credit_notes = CreditNote.where(:from_account_id => account.id)
        saccountings = Saccounting.where(:account_id => account.id)
        saccounting_lines = SaccountingLineItem.where(:from_account_id => account.id)

        flag = false
        if account.accountable.tax_rate.blank?
          # puts"  tax rate undifined, deleted!"

          nil_rate_deleted += 1
        elsif account.accountable.tax_rate <=0
          # puts"  tax rate is zero, deleted!"
          zero_rate_deleted += 1
        else
          if company.subscriptions[0].end_date.blank? 
            # puts"  company subscription not given, deleted!"
            invalid_subscriptions += 1
          elsif company.subscriptions[0].end_date.to_date <= "2013-03-31".to_date
            # puts"  company activation expired, deleted!"
            expired_subscriptions += 1
          else
            flag = true
            # puts"  converted tax account"
            converted += 1
          end
        end
        if flag
          name = account.name
          sales_tax_account = account
          account_head = AccountHead.find_by_company_id_and_name(company.id, "Duties and Taxes")
          sales_tax_account.name = "#{name}@#{account.accountable.tax_rate}% on sales"
          sales_tax_account.account_head_id = account_head.id
          sales_tax_account.accountable.apply_to = 1
          sales_tax_account.accountable.filling_frequency = 12
          sales_tax_account.save!
          purchase_tax_account = Account.new(:name => "#{name}@#{account.accountable.tax_rate}% on purchase",
            :company_id => company.id,:created_by => user.id, :account_head_id => account_head.id)
          sub_account = DutiesAndTaxesAccounts.new(:apply_to => 2, :tax_rate => account.accountable.tax_rate,
            :filling_frequency => 12)
          purchase_tax_account.accountable = sub_account
          purchase_tax_account.save!
          invoice_lines.each do |line|
            invoice = line.invoice
            invoice.invoice_line_items.update_all(:tax_account_id => sales_tax_account.id)
            invoice.update_and_post_ledgers
          end
          estimate_lines.each do |line|
            estimate = line.estimate
            estimate.estimate_line_items.update_all(:tax_account_id => sales_tax_account.id)
            EstimateLineItem.delete(estimate.tax_line_items)
            estimate.build_tax
          end
          purchase_lines.each do |line|
            purchase = line.purchase
            purchase.purchase_line_items.update_all(:tax_account_id => purchase_tax_account.id)
            purchase.update_and_post_ledgers
          end
          purchase_order_lines.each do |line|
            purchase_order = line.purchase_order
            purchase_order.purchase_order_line_items.update_all(:tax_account_id => purchase_tax_account.id)
            PurchaseOrderLineItem.delete(purchase_order.tax_line_items)
            purchase_order.build_tax
          end
        else
          # deleting invoicing
          invoice_lines.each do |line|
            line.invoice.destroy unless line.invoice.blank?
          end
          # deleting estimate
          estimate_lines.each do |line|
            line.estimate.destroy unless line.estimate.blank?
          end
          # deleting purchases
          purchase_lines.each do |line|
            line.purchase.destroy unless line.purchase.blank?
          end
          # deleting purchase order
          purchase_order_lines.each do |line|
            line.purchase_order.destroy unless line.purchase_order.blank?
          end
          # deleting journal
          journals.each do |journal|
            journal.destroy
          end
          # deleting journal lines
          journal_lines.each do |line|
            line.journal.destroy unless line.journal.blank?
          end
          # deleting saccounting
          saccountings.each do |saccounting|
            saccounting.destroy
          end
          saccounting_lines.each do |line|
            line.saccounting.destroy unless line.saccounting.blank?
          end
          #deleting debit note
          debit_notes.each do |note|
            note.destroy
          end
          # deleting credit notes
          credit_notes.each do |note|
            note.destroy
          end
          #deleting account itself
          account.destroy
        end
      end
      puts"nil rate deleted(#{nil_rate_deleted}), 0 rate deleted(#{zero_rate_deleted}), invalid subscriptions deleted(#{invalid_subscriptions}), deactivate deleted(#{expired_subscriptions}), converted(#{converted}) "
      Company.all.each do |company|
        parent_head = AccountHead.where(:company_id => company.id,:name => "Duties and Taxes")
        account_heads = AccountHead.get_parent_and_child_heads(company.id, parent_head)
        account_heads.each do |head|
          head.update_attributes(:deleted => true, :deleted_datetime => Time.now, :deleted_reason => "This head is moved in taxes")
        end
      end
    end
  end
end