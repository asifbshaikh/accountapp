module GstReturnsHelper
  
  def display_return_month
    "#{Date::MONTHNAMES[@gst_returns.month]} #{Time.now.to_date.year}"
  end
end
