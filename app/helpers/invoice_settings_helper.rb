module InvoiceSettingsHelper

  def selected_setting
    title = "I\'ll input my own invoice number."
    example = 'This field will be editable, you can enter whatever format you want, we will just ensure that this number is unique.'

    if @invoice_setting.invoice_no_strategy == InvoiceSetting::INVOICE_NUMBERING_STRATEGY[:random_number]
      title = '"INV"+Random unique number'
      example = "Example - INV1363684159"
    elsif @invoice_setting.invoice_no_strategy == InvoiceSetting::INVOICE_NUMBERING_STRATEGY[:prefix_with_sequence]
      title = '"INV"+ Sequence number'
      example = "Example: INV/100, INV/101 etc"
    elsif @invoice_setting.invoice_no_strategy == InvoiceSetting::INVOICE_NUMBERING_STRATEGY[:daily_reset_sequence_with_date]
      title = '"INV"+/yyyymmdd/Daily reset sequence number'
      example = "Example - INV/20130328/001, INV/20130328/002 and INV/20130329/001"
    elsif @invoice_setting.invoice_no_strategy == InvoiceSetting::INVOICE_NUMBERING_STRATEGY[:custom_format]
      title = 'Custom Prefix/ Custom starting sequence no / Custom prefix'
      example = "Wide range of invoice number setttings. Leave suffix or prefix or both blank, if not required. Example - IN/001, 2000/INV and 001"
    end
        html = (content_tag :h6, title)
        html += ( example)
    
  end
end
