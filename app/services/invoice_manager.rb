class InvoiceManager
  require 'invoice_b2b_rule'
  require 'invoice_b2cl_rule'
  require 'invoice_b2cs_rule'
  require 'export_invoice_rule'
  require 'nil_rated_invoice_rule'

  #Invoice Classification
  RULES = [InvoiceB2BRule.new, InvoiceB2CSRule.new, InvoiceB2CLRule.new, ExportInvoiceRule.new, NilRatedRule.new]

  def classify_invoice(invoice)
    type = nil
    RULES.each do |rule|
      type = rule.classify(invoice)
      if type.present?
        break 
      end
    end
    Rails.logger.debug "classification is #{type}"
    type
  end

end