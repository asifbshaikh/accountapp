class InvoiceSetting < ActiveRecord::Base
  belongs_to :company

  INVOICE_NUMBERING_STRATEGY = {:random_number => 0, :prefix_with_sequence => 1, :daily_reset_sequence_with_date => 2, :custom_format => 3, :free_format => 4}

  def footer_enabled?
    !invoice_footer.blank?
  end

  ##Naveen 29-Jun-2017
  #This method returns the current sequence number +1. 
  #It does not increment the sequence number
  #The sequence number will be incremented only when invoice is saved
  def allocate_invoice_number
    if invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:random_number]
      random_invoice_number
    elsif invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:prefix_with_sequence]
      inv_no = self.invoice_sequence+1
      "#{self.invoice_prefix}/#{inv_no.to_s.rjust(3,'0')}"
    elsif invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:daily_reset_sequence_with_date]
      inv_no = self.invoice_sequence+1
      'INV/'+Time.zone.now.to_date.to_s(:number)+"/"+inv_no.to_s.rjust(3,'0')
    elsif invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:custom_format]
      inv_no = self.invoice_sequence+1
      invoice_number = ""
      invoice_number += self.invoice_prefix + "/" unless self.invoice_prefix.blank?
      invoice_number += inv_no.to_s.rjust(3,'0')
      invoice_number += "/" + self.invoice_suffix unless self.invoice_suffix.blank? 
      invoice_number #return the custom invoice number
    end  
  end

  def invoice_number
    if invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:random_number]
      random_invoice_number
    elsif invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:prefix_with_sequence]
      sequence_invoice_number
    elsif invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:daily_reset_sequence_with_date]
      daily_sequence_invoice_number
    elsif invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:custom_format]
      custom_format
    else
      ""
    end
  end

  def free_format?
    self.invoice_no_strategy == INVOICE_NUMBERING_STRATEGY[:free_format]
  end

  private

    def random_invoice_number
      'INV'+Time.now.to_i.to_s
    end

    def sequence_invoice_number
      InvoiceSetting.increment_counter(:invoice_sequence, self.id)
      self.reload
      "#{self.invoice_prefix}/#{self.invoice_sequence.to_s.rjust(3,'0')}"
    end

    def daily_sequence_invoice_number
      InvoiceSetting.increment_counter(:invoice_sequence, self.id)
      self.reload
      'INV/'+Time.zone.now.to_date.to_s(:number)+"/"+self.invoice_sequence.to_s.rjust(3,'0')
    end

    def custom_format
      InvoiceSetting.increment_counter(:invoice_sequence, self.id)
      self.reload
      invoice_number = ""
      invoice_number += self.invoice_prefix + "/" unless self.invoice_prefix.blank?
      invoice_number += self.invoice_sequence.to_s.rjust(3,'0')
      invoice_number += "/" + self.invoice_suffix unless self.invoice_suffix.blank? 
      invoice_number #return the custom invoice number
    end
end