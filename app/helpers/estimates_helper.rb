module EstimatesHelper
  def estimate_line_count
    columns=5
    columns+=1 if @estimate.get_discount>0
    columns+=2 if @estimate.has_tax_lines?
    columns
  end 

  def estimate_customer_details
    content_tag :div, :class=> 'col-sm-5' do 
      details = content_tag :h4, (content_tag :strong, @estimate.account.name)
      details += address

      if !@estimate.account.accountable.email.blank?
        details += content_tag :p do
            content_tag :i, @estimate.account.accountable.email, :class => 'icon-envelope-alt'
          end
      end

      if !@estimate.account.accountable.contact_number.blank?
        details += content_tag :p do
            content_tag :i, @estimate.account.accountable.contact_number, :class => 'icon-phone'
          end
      end

      details
    end
  end
def estimate_status_badge
    status = @estimate.get_status
    if status == 'Invoiced'
      "success"
    elsif status == 'Converted to SO'
      "info"
    end
 end

end
