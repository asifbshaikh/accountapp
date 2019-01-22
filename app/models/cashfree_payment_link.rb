class CashfreePaymentLink < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :company
  has_one :webhook_payments
  validates_presence_of :customer_phone, :message => "Customer Mobile Number can not be blank"
  validates_presence_of :customer_email, :message => "Customer Email can not be blank"
  validates_presence_of :shorturl, :customer_name
	def self.create_new(params,app_id,secret_key,company,remote_ip)

        # headers={'X-Api-Key'=> api_key.to_s,'X-Auth-Token'=> auth_key.to_s} # Api-Key and Token of Profitbooks to be replaced by customer credentials
      data={'appId'=> app_id.to_s,
 			'secretKey'=> secret_key.to_s,
      'pc' => 'CFM002',
      'orderId'=> params[:cf_order_id].to_s,
 			'orderAmount'=> params[:invoice_amount].to_s,
      'customerName' =>params[:name].to_s,
      'customerPhone'=> params[:phone].to_s,
      'customerEmail'=> params[:email].to_s,
 			'returnUrl' => 'https://www.profitbookshq.com/webhook/cashfree_callback',
 			'notifyUrl' => 'https://www.profitbookshq.com/webhook/cashfree_callback',
      # 'returnUrl' => 'http://www.profitnext.com/webhook/cashfree_callback',
      # 'notifyUrl' => 'http://www.profitnext.com/webhook/cashfree_callback',
      'mode'=> 'ONLINE'
        } 
          url = URI.parse("https://api.gocashfree.com/api/v1/order/create")
          # url = URI.parse("https://test.gocashfree.com/api/v1/order/create")
          req = Net::HTTP::Post.new(url.request_uri)
          req.set_form_data(data)
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = (url.scheme == "https")
          response = http.request(req)
          puts response.body
          
		   result = JSON.parse(response.body)
		   puts result["paymentLink"]

          paymentlink=CashfreePaymentLink.new
          paymentlink.company_id = company.id
          paymentlink.invoice_id = params[:id]
          paymentlink.order_id=params[:cf_order_id]
          paymentlink.order_amount=params[:invoice_amount]
          paymentlink.customer_id=params[:customer_id]
          paymentlink.customer_name=params[:name]
          paymentlink.customer_phone=params[:phone]
          paymentlink.customer_email=params[:email]
          paymentlink.shorturl=result["paymentLink"]
          paymentlink.created_by=params[:created_by]
          paymentlink.status = result["status"]
          paymentlink.save!                 

	end
  def self.update(params,app_id,secret_key,company,remote_ip)
     @orderdetails= CashfreePaymentLink.find_by_order_id(params[:cf_order_id].to_s)
      data={ 'pc' => 'CFM002','appId'=> app_id.to_s,
      'secretKey'=> secret_key.to_s,
      'orderId'=> params[:cf_order_id].to_s,
      'orderAmount'=> params[:invoice_amount].to_s,
      'notifyUrl' => 'http://www.profitbookshq.com/webhook/cashfree_callback',
      'mode'=> 'ONLINE'
        } 
          url = URI.parse("https://api.gocashfree.com/api/v1/order/update")
          req = Net::HTTP::Post.new(url.request_uri)
          req.set_form_data(data)
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = (url.scheme == "https")
          response = http.request(req)
          puts response.body
          @orderdetails.update_attributes(:order_amount=>params[:invoice_amount].to_s)
  end



 def register_user_action(remote_ip, action)
        Workstream.register_user_action(company_id, created_by, remote_ip,
      " #{invoice_number} for customer #{customer_name} for amount #{number_with_precision total_amount,:precision=>2}", action, branch_id)
end


end
