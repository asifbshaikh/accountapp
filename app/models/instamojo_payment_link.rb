class InstamojoPaymentLink < ActiveRecord::Base
	belongs_to :invoice
	belongs_to :company
  has_one :webhook_payments
	require 'json'



	def self.create_new(params,api_key,auth_key,company,remote_ip)

         
        @sms_default="False"

        if  params[:send_sms].to_s=="True" &&  params[:phone].to_s!=""
             @sms_default="True"
        end

        headers={'X-Api-Key'=> api_key.to_s,'X-Auth-Token'=> auth_key.to_s} # Api-Key and Token of Profitbooks to be replaced by customer credentials
        data={'allow_repeated_payments'=> 'False',
         'amount'=> params[:invoice_amount].to_s, 
         'buyer_name'=> params[:name].to_s, 
         'email'=> params[:email].to_s, 
         'phone'=> params[:phone].to_s , 
         'purpose'=> params[:invoice_number].to_s, 
         'redirect_url'=> 'https://www.profitbookshq.com/signup/new', 
         'send_email'=> 'False', 
         'send_sms'=> @sms_default, 
         'webhook'=> 'https://www.profitbookshq.com/webhook/payment_callback' 
        } 

          url = URI.parse("https://www.instamojo.com/api/1.1/payment-requests/")
          req = Net::HTTP::Post.new(url.request_uri,headers)
          req.set_form_data(data)
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = (url.scheme == "https")
          response = http.request(req)
          puts response.body #to be commented
          puts response.code #to be commented
		      result = JSON.parse(response.body)
          paymentlink=InstamojoPaymentLink.new
		      paymentlink.company_id = company.id
    	    paymentlink.invoice_id = params[:id]
    	    paymentlink.payment_request_id=result["payment_request"]["id"]

    	    paymentlink.purpose=params[:invoice_number]
    	    paymentlink.amount=params[:invoice_amount]
          paymentlink.customer_id=params[:customer_id]
          paymentlink.customer_name=params[:name]
    	    paymentlink.longurl=result["payment_request"]["longurl"]
    	    paymentlink.shorturl=result["payment_request"]["shorturl"]
    	    paymentlink.created_by=params[:created_by]
          paymentlink.status = result["payment_request"]["status"]
          paymentlink.save!
          

	end

   def register_user_action(remote_ip, action)
        Workstream.register_user_action(company_id, created_by, remote_ip,
      " #{invoice_number} for customer #{customer_name} for amount #{number_with_precision total_amount,:precision=>2}", action, branch_id)
   end

   

end
