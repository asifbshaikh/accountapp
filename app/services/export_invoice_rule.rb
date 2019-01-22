class ExportInvoiceRule
		def classify(invoice) 

              if invoice.export_invoice?
              	type = 'EXP'
              	type
              end
          
		end
  
end
