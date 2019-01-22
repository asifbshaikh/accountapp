class GstDebitNoteWorker < ActiveRecord::Base
	include Sidekiq::Worker

	def self.perform(purchase_return,remote_ip,company_id)
		@company = Company.find(company_id)
		gst_debit_note = GstDebitNote.new
		gst_debit_note.company_id = purchase_return.company_id
		gst_debit_note.gst_debit_note_date = purchase_return.record_date
		gst_debit_note.amount = purchase_return.total_amount
		gst_debit_note.from_account_id = purchase_return.account_id
		gst_debit_note.purchase_return_id = purchase_return.id
		gst_debit_note.status_id = 0
		gst_debit_note.created_by = purchase_return.created_by
		gst_debit_note.branch_id = purchase_return.branch_id
		gst_debit_note.gst_debit_note_number = VoucherSetting.next_gst_debit_number(gst_debit_note.company)

		purchase_return.purchase_return_line_items.each do |purchase_return_line_item|
			gst_debit_note_line_item = GstDebitNoteLineItem.new
			gst_debit_note_line_item.gst_debit_note_id = gst_debit_note.id
			gst_debit_note_line_item.account_id = purchase_return_line_item.account_id
			gst_debit_note_line_item.to_account_id = purchase_return_line_item.product.income_account_id
			gst_debit_note_line_item.quantity = purchase_return_line_item.quantity
			gst_debit_note_line_item.unit_rate = purchase_return_line_item.unit_rate
			gst_debit_note_line_item.tax = purchase_return_line_item.tax
			gst_debit_note_line_item.amount = purchase_return_line_item.amount
			gst_debit_note_line_item.product_id = purchase_return_line_item.product_id
			gst_debit_note_line_item.tax_account_id = purchase_return_line_item.tax_account_id
			gst_debit_note_line_item.discount_percent = purchase_return_line_item.discount_percent
			gst_debit_note_line_item.line_type = "GstDebitNoteLineItem"
			
			purchase_return_line_item.purchase_return_taxes.each do |purchase_return_taxes|
				gst_debit_note_line_item.gst_debit_note_taxes << GstDebitNoteTax.new(:account_id=>purchase_return_taxes.account_id)
			end
			gst_debit_note.gst_debit_note_line_items << gst_debit_note_line_item
		end
		gst_debit_note.build_tax
		gst_debit_note.save!
		gst_debit_note.register_user_action(remote_ip, "created")
		gst_debit_note.save_with_ledgers
		VoucherSetting.next_gst_debit_write(gst_debit_note.company_id)

		begin 
          gst_debit_note_month = gst_debit_note.gst_debit_note_date.month
          @gst_returns = @company.gst_returns.return_month(gst_debit_note_month)
          if @gst_returns.present? && @gst_returns.gstr_two.present?
            @gst_returns.gstr_two.add_gst_debit_note(gst_debit_note)
          end
        rescue Exception => e
          Sidekiq.logger.error e
          ErrorMailer.experror(e, @company.users.first, "GstDebitNoteWorker for #{gst_debit_note.id}").deliver
        end   

	end

	def self.update_gst_debit_note(purchase_return,remote_ip)
		gst_debit_note = GstDebitNote.find_by_purchase_return_id(purchase_return.id)
		gst_debit_note_line_item = gst_debit_note.gst_debit_note_line_items
		gst_debit_note_line_item.each do |gst_line_item|
			gst_line_item.gst_debit_note_taxes do |tax|
				tax.mark_for_destruction
			end
			gst_line_item.mark_for_destruction
		end
		gst_debit_note.tax_line_items.each do |gst_tax_line_item|
			gst_tax_line_item.mark_for_destruction
		end
		purchase_return.purchase_return_line_items.each do |purchase_return_line_item|

			gst_debit_note_line_item = GstDebitNoteLineItem.new
			gst_debit_note_line_item.gst_debit_note_id = gst_debit_note.id
			gst_debit_note_line_item.account_id = purchase_return_line_item.account_id
			gst_debit_note_line_item.to_account_id = purchase_return_line_item.product.income_account_id
			gst_debit_note_line_item.quantity = purchase_return_line_item.quantity
			gst_debit_note_line_item.unit_rate = purchase_return_line_item.unit_rate
			gst_debit_note_line_item.tax = purchase_return_line_item.tax
			gst_debit_note_line_item.amount = purchase_return_line_item.amount
			gst_debit_note_line_item.product_id = purchase_return_line_item.product_id
			gst_debit_note_line_item.tax_account_id = purchase_return_line_item.tax_account_id
			gst_debit_note_line_item.discount_percent = purchase_return_line_item.discount_percent
			gst_debit_note_line_item.line_type = "GstDebitNoteLineItem"
			
			purchase_return_line_item.purchase_return_taxes.each do |purchase_return_taxes|
				gst_debit_note_line_item.gst_debit_note_taxes << GstDebitNoteTax.new(:account_id=>purchase_return_taxes.account_id)
			end
			gst_debit_note.gst_debit_note_line_items << gst_debit_note_line_item
		end
		gst_debit_note.build_tax
		gst_debit_note.amount = purchase_return.get_total_amount
		gst_debit_note
		gst_debit_note.update_and_post_ledgers
		gst_debit_note.register_user_action(remote_ip, "updated")

	end
end