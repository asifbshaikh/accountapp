 ActionMailer::Base.smtp_settings = {  
  # :address => "smtp.mandrillapp.com",
  # :port => 587,
  # :user_name=> "support@profitbooks.net",
  # :password=> "Ytq_Dfs65FD7Stp0O2708A"
  # :address => "smtp.mandrillapp.com",
  # :port => 587,
  # :user_name=> "mohnish@profitbooks.net",
  # :password=> "RZs99T9eZAbIgZZrLXIYxA"

  # :address => "smtp.sendgrid.net",
  # :port => 587,
  # :user_name=> "apikey",
  # :password=> "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"

  :address => "email-smtp.us-east-1.amazonaws.com",  
  :port => 587,  
  :user_name=> "AKIAIB36CG5Z565UCZFQ",  
  :password=> "AiUwgtWEOfn1VbKKA6Ex51P+/Mv/a6G0p0KrTX0kh9oT"


 }
 ActionMailer::Base.default_url_options[:host] = "profitbookshq.com"
 ActionMailer::Base.delivery_method = :smtp
 ActionMailer::Base.raise_delivery_errors = true