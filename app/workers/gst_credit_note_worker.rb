class GstCreditNoteWorker < ActiveRecord::Base
  include Sidekiq::Worker

   def self.perform(invoice_return, remote_ip, company_id)
      @company = Company.find(company_id)
   	  gst_credit_note = GstCreditNote.new
      gst_credit_note.invoice_return_id = invoice_return.id
      gst_credit_note.company_id = invoice_return.company_id
      gst_credit_note.to_account_id = invoice_return.account_id
      gst_credit_note.branch_id = invoice_return.branch_id
      gst_credit_note.gst_credit_note_date = invoice_return.record_date
      gst_credit_note.amount = invoice_return.total_amount
      gst_credit_note.created_by = invoice_return.created_by
      gst_credit_note.gst_credit_note_number = VoucherSetting.next_gst_credit_note_number(company_id)
      gst_credit_note.status_id = 0

      
      invoice_return.invoice_return_line_items.each do |line_item|
         
  		gst_credit_note_line_item = GstCreditNoteLineItem.new
            gst_credit_note_line_item.product_id = line_item.product_id
            gst_credit_note_line_item.account_id = line_item.account_id
            gst_credit_note_line_item.from_account_id = line_item.product.income_account_id
            gst_credit_note_line_item.quantity = line_item.quantity
            gst_credit_note_line_item.unit_rate = line_item.unit_rate
            gst_credit_note_line_item.discount_percent = line_item.discount_percent
            gst_credit_note_line_item.amount = line_item.amount
            gst_credit_note_line_item.line_type ="GstCreditNoteLineItem"
  			
          line_item.invoice_return_taxes.each do |tax|
            gst_credit_note_line_item.gst_credit_note_taxes<<GstCreditNoteTax.new(:account_id => tax.account_id)
          end
          gst_credit_note.gst_credit_note_line_items << gst_credit_note_line_item
        end
        gst_credit_note.build_tax
        gst_credit_note.save!
        gst_credit_note.register_user_action(remote_ip, 'created')
        gst_credit_note.save_with_ledgers
        VoucherSetting.next_gst_credit_note_number_write(company_id)
        # gstr_one_items = GstrOneItem.new
        # gstr_one_items.company_id = gst_credit_note.company_id
        # gstr_one_items.gstr_one_id = 
        # gstr_one_items.voucher_id = gst_credit_note.id
        # gstr_one_items.voucher_type = "GstCreditNote"
        # rule = GstCreditNoteRule.new
        # if rule.classify(gst_credit_note).present?
        #   gstr_one_items.voucher_classification = 5
        # else
        #   gstr_one_items.voucher_classification = 6
        # end
        # gstr_one_items.save!

        begin 
          gst_credit_note_month = gst_credit_note.gst_credit_note_date.month
          @gst_returns = @company.gst_returns.return_month(gst_credit_note_month)
          if @gst_returns.present? && @gst_returns.gstr_one.present?
            @gst_returns.gstr_one.add_gst_credit_note(gst_credit_note)
          end
        rescue Exception => e
          Sidekiq.logger.error e
          ErrorMailer.experror(e, @company.users.first, "GstCreditNoteWorker for #{gst_credit_note.id}").deliver
          #raise e
        end   



  	end

    def self.update_gst_credit_note(invoice_return, params, remote_ip, company)
      gst_credit_note = GstCreditNote.find_by_invoice_return_id(invoice_return.id)
      gst_credit_note_line_item = gst_credit_note.gst_credit_note_line_items

      gst_credit_note_line_item.each do |line_item|

        line_item.gst_credit_note_taxes.each do |tax|
          tax.mark_for_destruction
        end
        
        line_item.mark_for_destruction
      end

      gst_credit_note.tax_line_items.each do |line_item|
        line_item.mark_for_destruction
      end
      # invoice_return.reload

      invoice_return.invoice_return_line_items.each do |line_item|
            gst_credit_note_line_item = GstCreditNoteLineItem.new
            gst_credit_note_line_item.product_id = line_item.product_id
            gst_credit_note_line_item.account_id = line_item.account_id
            gst_credit_note_line_item.from_account_id = line_item.product.income_account_id
            gst_credit_note_line_item.quantity = line_item.quantity
            gst_credit_note_line_item.unit_rate = line_item.unit_rate
            gst_credit_note_line_item.discount_percent = line_item.discount_percent
            gst_credit_note_line_item.amount = line_item.amount
            gst_credit_note_line_item.line_type ="GstCreditNoteLineItem"

            line_item.invoice_return_taxes.each do |tax|
            gst_credit_note_line_item.gst_credit_note_taxes<<GstCreditNoteTax.new(:account_id => tax.account_id)
          end
          gst_credit_note.gst_credit_note_line_items << gst_credit_note_line_item
      end
      gst_credit_note.build_tax
      gst_credit_note.amount = invoice_return.get_total_amount
      gst_credit_note

      gst_credit_note.update_and_post_ledgers
      gst_credit_note.register_user_action(remote_ip, 'updated')
    end
end