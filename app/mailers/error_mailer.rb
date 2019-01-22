class ErrorMailer < ActionMailer::Base

  def experror(e, user, request_url)
    @err = e
    @user = user
    @request_url = request_url
    mail(:to => "naveen@profitbooks.net", :from => "naveen@profitbooks.net" , :subject => "#{@err.message}")
  end

  def gst_experror(e, request, response, user, request_url)
    @err = e
    @user = user
    @request_url = request_url
    @request = request
    @response = response
    mail(:to => "support@profitbooks.net", :from => "naveen@profitbooks.net" , :subject => "#{@err.message}")
  end

end
