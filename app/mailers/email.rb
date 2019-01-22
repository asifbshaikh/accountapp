class Email < ActionMailer::Base

  def daily_lead_activity(total_registrations,total_paid,lead_demo,trial_demo_online,trial_demo_presonal_visit,total_lead_activities,total_customer_relationships_activities)
    @total_registrations = total_registrations
    @total_paid = total_paid
    @lead_demo = lead_demo
    @trial_demo_online = trial_demo_online
    @trial_demo_presonal_visit = trial_demo_presonal_visit
    @total_lead_activities = total_lead_activities
    @total_customer_relationships_activities = total_customer_relationships_activities
    mail(:to => "leads@thenextwave.in", :subject => "Daily Status Mail", :from => "connect@profitbooks.in <support@profitbooks.net>",:reply_to => "connect@profitbooks.in")
  end

  def admin_morning_mail
    # mails are asked to stop by Harshal sir.
    # @super_users = SuperUser.all
    # mail(:to => "leads@thenextwave.in", :subject => "Schedule For Day", :from => "connect@profitbooks.in")
  end

  def admin_evening_mail
    @super_users = SuperUser.all
    mail(:to => "leads@thenextwave.in", :subject => "Daily Status Mail", :from => "connect@profitbooks.in <support@profitbooks.net>",:reply_to => "connect@profitbooks.in")
  end

  def send_leads_email(to_email,cc,subject,text,from,mail_sender)
    @text = text
    @mail_sender = mail_sender
    # attachments["ProfitBooks"] = file
    mail(:to => to_email, :cc => cc, :subject => subject, :from => '#{from}<support@profitbooks.net>',:reply_to => from)
  end

  def payroll_history(payroll_execution_jobs, fail_companies, unprocessed_users, attendance_not_taken_users)
    @payroll_execution_jobs = payroll_execution_jobs
    @companies = fail_companies
    @users = unprocessed_users
    @attendance_not_taken_users = attendance_not_taken_users
    mail(:to => "support@thenextwave.in", :bcc=> "manjeet@thenextwave.in",
      :from => "support@profitbooks.net" , :subject => "Payroll processing history on #{Time.zone.now}",:reply_to => "support@profitbooks.net")
  end


  def delete_user_confirmation(user)
    @user = user
    mail(:to => user.email,:from => "support@profitbooks.net" , :subject => 'Confirmation for deactivation of User',:reply_to => "support@profitbooks.net")
  end

  def restore_user_confirmation(user)
    @user = user
    mail(:to => user.email,:from => "support@profitbooks.net" , :subject => 'ProfitBooks account activated',:reply_to => "support@profitbooks.net")
  end

  def activation_user_confirmation(current_user, user)
    @current_user = current_user
    @user = user
    mail(:to =>@current_user.email,:from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject => 'Notification : User has been restored',:reply_to => "support@profitbooks.net")
  end

  def task_created(task, current_user)
    @task = task
    @user = User.find(@task.assigned_to)
    mail(:to =>@user.email, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject => "Task Created",:reply_to => current_user.email )
  end

  #invitation for share folder
  def invitation_to_share(shared_folder)
    @shared_folder = shared_folder #setting up an instance variable to be used in the email template
    mail( :to => @shared_folder.shared_email,
     :subject => "#{@shared_folder.user.name} wants to share '#{@shared_folder.folder.name}' folder with you" )
  end

  def user_created(user, random_str)
    @user = user
    @random_str = random_str
    mail(:to => user.email, :bcc => "harshal@thenextwave.in", :from=> "support@profitbooks.net",
      :subject => 'Welcome to ProfitBooks',:reply_to=> "support@profitbooks.net")
  end

  #Added this to communicate the temporary password to newly created user
  #Author: Ashish Wadekar
  #Date: 19th October 2016
  def welcome_email(user, random_str)
    @user = user
    @random_str = random_str
    mail(:to => user.email, :bcc => "harshal@thenextwave.in, naveen@profitbooks.net", :from=> "support@profitbooks.net",
      :subject => 'Welcome to Profitbooks!',:reply_to=> "support@profitbooks.net")
  end

  def verify_email(user, subscription)
    @user = user
    @subscription = subscription
    mail(:to => user.email, :bcc => "harshal@thenextwave.in", :from=> "ProfitBooks Team <support@profitbooks.net>",
      :subject => 'Activate your ProfitBooks Account',:reply_to=> "support@profitbooks.net")
  end

  def signup_confirmation(user, plan)
    @user = user
    @plan = plan
    mail(:to => user.email, :bcc => "harshal@thenextwave.in, naveen@profitbooks.net",
     :from=> "ProfitBooks Team<support@profitbooks.net>", :subject => 'Welcome to ProfitBooks',:reply_to=> "support@profitbooks.net")
  end

  def feedback_created(feedback, current_user)
    email = "support@profitbooks.net"
    @user = current_user
    @feedback = feedback
    mail(:to => email, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject => @feedback.vote,:reply_to=> "current_user.email")
  end

  def support_created(support, current_user)
    email = "support@profitbooks.net"
    @support = support
    @user = current_user
    mail(:to => email, :subject => "Support Received")
  end

  def reset_password(user, pass)
    @user = user
    @password = pass
    email = user.email
    mail(:to => email, :from => "support@profitbooks.net", :subject => "Password Reset",:reply_to=>"support@profitbooks.net")
  end

  def auditor_reset_password(auditor, pass)
    @auditor = auditor
    @password = pass
    email = auditor.username
    mail(:to => email, :from => "support@profitbooks.net", :subject => "Password Reset",:reply_to=>"support@profitbooks.net")
  end

  def got_username(user)
    @user = user
    email = @user.email
    mail(:to => email, :from => "support@profitbooks.net", :subject => "Username", :reply_to=>"support@profitbooks.net")
  end

  def website_form(from_email, message, name, contact)
    @name = name
    @message = message
    @contact = contact
    email = "support@profitbooks.net"
    mail(:to => email, :from => '#{from_email} <support@profitbooks.net>', :subject => "Website enquiry form",:reply_to=>from_email)
  end

  def user_feedback(from_email, message)
    @message = message
    email = "support@profitbooks.net"
    mail(:to => email, :from => '#{from_email}<support@profitbooks.net>', :subject => "User Feedback",:reply_to=>from_email)
  end

  def webinar_registration(name, from_email,  phone)
    @name = name
    # @date = date
    @phone = phone
    to_email = "support@profitbooks.net"
    mail(:to => to_email, :from=> '#{from_email}<support@profitbooks.net>', :subject=>"New webinar enrollment",:reply_to=>from_email)
  end

  def webinar_confirmation_to_user(name,to_email, phone)
    @name = name
    # @date = date
    @phone = phone
    from_email = "support@profitbooks.net"
    mail(:to => to_email, :from=> '#{from_email} <support@profitbooks.net>', :subject=>"Thanks for registering for ProfitBooks webinar",:reply_to=>from_email)
  end

  def upgrade_version(requested_plan, plan, current_user, current_company)
    @requested_plan = requested_plan
    @plan = plan
    @user = current_user
    @company = current_company
    from_email = current_user.email
    mail(:to =>"support@profitbooks.net" , :bcc => "harshal@thenextwave.in, naveen@profitbooks.net",
     :from=> "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>" , :subject => 'Upgrade Plan version',:reply_to=>from_email)
  end


  # Payroll process emails
  def payroll_request(user, current_company)
    @user = user
    @company = current_company
    to = current_company.users.first
    email = to.email
    mail(:to => email, :bcc => "support@ProfitBooks.net", :from => "support@profitbooks.net",
     :subject => "Payroll request submitted successfully.",:reply_to => "support@profitbooks.net")
  end

  def payroll_processed(user, company)
    @user = user
    @company = company
    email = company.users.first.email
    mail(:to => email, :bcc => "support@profitbooks.net", :from => "support@profitbooks.net",
     :subject => "Your payroll has been processed",:reply_to => "support@profitbooks.net")
  end


  def admin_mail(to_email)
    # @user = user
    # attachments["ProfitBooks Product Details-2014.pdf"] = file
    subject = "Struggling to keep finances in order?"
    mail(:to => to_email, :subject => subject, :from => "sneha@profitbooks.net",:reply_to => "support@profitbooks.net")
  end

  def weekly_mail(user, company, date, income, expense, receivable_account,payable_account,bank_account, cash_account, header, footer)
    @company = company
    @user = user
    @date = date
    @income = income
    @expense = expense
    @receivable_hash = receivable_account
    @payable_hash = payable_account
    @bank_hash = bank_account
    @cash_hash = cash_account
    @header = header
    @footer = footer
    email = "naveen@profitbooks.net"
    mail(:to => email,:from => "support@profitbooks.net", :subject => "Weekly report from your ProfitBooks account",:reply_to => "support@profitbooks.net")
  end

  def send_billing_invoice(file, billing_invoice, company, user)
    @billing_invoice = billing_invoice
    @user = user
    @company = company
    attachments["#{billing_invoice.invoice_number}.pdf"] = file
    mail(:to => @user.email, :bcc => "support@profitbooks.net", :from=> "support@profitbooks.net", :subject => 'Profitbooks billing invoice',:reply_to => "support@profitbooks.net")
  end

  #sending invoice as attachment in an email
  def send_invoice(file, invoice, current_company, current_user, subject, text, to_email, cc)
    @company = current_company
    @invoice = invoice
    @user = current_user
    @subject = subject
    @text = text
    attachments["#{invoice.invoice_number}.pdf"] = file
    from_email = current_user.email
    mail(:to => to_email, :cc => cc, :from =>"\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>" ,:reply_to => current_user.email, :subject=> subject)
  end


  def send_cashfree_docs(file,current_company, current_user, subject, to_email, bcc)
    @company = current_company
    @user = current_user
    @subject = subject
    @file=file
    attachments["#{file.uploaded_file_one_file_name}"] = open(@file.uploaded_file_one.url) {|f| f.read}
    attachments["#{file.uploaded_file_two_file_name}"] = open(@file.uploaded_file_two.url) {|f| f.read}
    attachments["#{file.uploaded_file_three_file_name}"] = open(@file.uploaded_file_three.url) {|f| f.read}
    from_email = current_user.email
    mail(:to => to_email, :bcc => bcc, :from =>"\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>" ,:reply_to => current_user.email, :subject=> subject)
  end

  #sending recursive invoice as attachment in an email
  # def send_recursive_invoice(file, invoice, current_company, current_user, subject, text, to_email, receiver)
  #   @company = current_company
  #   @invoice = invoice
  #   @user = current_user
  #   @subject = subject
  #   @text = text
  #   @receiver = receiver
  #   attachments["#{invoice.invoice_number}.pdf"] = file
  #   from_email = current_user.email
  #   mail(:to => to_email, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject=> subject,:reply_to => from_email)
  # end

  #sending receipt_voucher as attachment in an email
  def send_receipt(file, receipt_voucher, current_company, current_user, subject, text, to_email)
    @company = current_company
    @receipt_voucher = receipt_voucher
    @user = current_user
    @subject = subject
    @text = text
    attachments["#{receipt_voucher.voucher_number}.pdf"] = file
      #email = invoice.account.accountable.email
      from_email = current_user.email
      mail(:to => to_email, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject=> subject,:reply_to => from_email)
    end

  #sending estimate as attachment in an email
  def send_estimate(file, estimate, current_company, current_user, subject, text, to_email)
    @company = current_company
    @estimate = estimate
    @user = current_user
    @subject = subject
    @text = text
    attachments["#{estimate.estimate_number}.pdf"] = file
    attachments["#{estimate.file_name}"] = open(estimate.attachment.url).read unless estimate.file_name.blank?
    from_email = current_user.email
    mail(:to => to_email, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject=> subject,:reply_to => from_email)
  end

def  send_gstr_advance_receipt(file, gstr_advance_receipt, current_company, current_user, subject, text, to_email)
    @company = current_company
    @gstr_advance_receipt = gstr_advance_receipt
    @user = current_user
    @subject = subject
    @text = text
    attachments["#{gstr_advance_receipt.voucher_number}.pdf"] = file
    #attachments["#{gstr_advance_receipt.file_name}"] = open(gstr_advance_receipt.attachment.url).read unless gstr_advance_receipt.file_name.blank?
    from_email = current_user.email
    mail(:to => to_email, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject=> subject,:reply_to => from_email)
  end




  #sending PO as attachment in an email
  def send_purchase_order(file, purchase_order, current_company, current_user, subject, text, to_email, cc)
    @company = current_company
    @purchase_order = purchase_order
    @user = current_user
    @subject = subject
    @text = text
    attachments["#{purchase_order.purchase_order_number}.pdf"] = file
    from_email = current_user.email
    mail(:to => to_email,:cc => cc, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject=> subject,:reply_to => from_email)
  end

  #sending Reimbursement Note as attachment in an email
  def send_reimbursement_note(file, reimbursement_note, current_company, current_user, subject, text, to_email, cc)
    @company = current_company
    @reimbursement_note = reimbursement_note
    @user = current_user
    @subject = subject
    @text = text
    attachments["#{reimbursement_note.reimbursement_note_number}.pdf"] = file
    from_email = current_user.email
    mail(:to => to_email,:cc => cc, :from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject=> subject,:reply_to => from_email)
  end

  #sending customer statement as attachment in an email
  def send_customer_statement(file,customer, invoices, receipt_vouchers, balance_amount, current_company, current_user, subject, text, to_email, cc)
    # @start_date = start_date
    # @end_date = end_date
    @company = current_company
    @customer = customer
    @invoices = invoices
    @receipt_vouchers = receipt_vouchers
    @balance_amount = balance_amount
    @user = current_user
    @subject = subject
    @text = text
    attachments["customer_statement.pdf"] = file
    from_email = current_user.email
    mail(:to => to_email, :cc => cc ,:from => "\"#{current_user.first_name} #{current_user.last_name}\"<support@profitbooks.net>", :subject=> subject,:reply_to => from_email)
  end

  def auditor_invitation(invitation_detail)
    @invitation_detail = invitation_detail
    @company = Company.find @invitation_detail.company_id
    mail(:to => @invitation_detail.email, :bcc => "harshal@thenextwave.in,naveen@profitbooks.net", :from=> "support@profitbooks.net",:reply_to=> "support@profitbooks.net", :subject => "Auditor request from #{@company.name}." )
  end

  def client_invitation(client_invite)
    @client_inviting = client_invite
    @auditor = Auditor.find_by_id(@client_inviting.sent_by)
    #@company = Company.find @client_invitation.company_id
    mail(:to => @client_inviting.email, :bcc => "harshal@thenextwave.in,naveen@profitbooks.net,noobrohit@gmail.com", :from=> "support@profitbooks.net",:reply_to=> "support@profitbooks.net", :subject => "Client request from your Auditor")
  end

  # def send_demo_requests(lead)
  #   @leads=lead
  #   @lead_activity=@leads.lead_activities.where(:lead_activities=>{next_activity: 2,:activity_status=>0}).order('created_at ASC').last

  #   # mail(:to => @leads.email, :bcc => "harshal@thenextwave.in,naveen@profitbooks.net", :from=> "support@profitbooks.net",:reply_to=> "support@profitbooks.net", :subject => "Scheduled ProfitBooks Demo." )
  #   # mail(:to => 'rohit@thenextwave.in', :bcc => "rohit@thenextwave.in", :from=> "support@profitbooks.net",:reply_to=> "support@profitbooks.net", :subject => "Scheduled ProfitBooks Demo." )
  #   mail(:to => 'rohit@thenextwave.in',:from => "support@profitbooks.net", :subject => "Weekly report from your ProfitBooks account",:reply_to => "support@profitbooks.net")
  # end

  def send_demo_requests(lead)
    @leads = lead
    subject="Your ProfitBooks demo has been scheduled!"
    to_email= @leads.email
    bcc = "Harshal Katre <harshal@profitbooks.net>, Samatha <samatha@profitbooks.net>, Ravi Rana <ravi@profitbooks.net>, Mohit Mogha <mohit@profitbooks.net>, Naveen <naveen@profitbooks.net>"
    @subject = subject
    mail(:to => to_email, :bcc => bcc, :from =>"ProfitBooks Team <support@profitbooks.net>" ,:reply_to =>"ProfitBooks Team <support@profitbooks.net>" , :subject=> subject)
  end

  def call_me(user,company)
     @user = user
     @company=company
     subject="Bookkeeping & Legal services request"
     to_email="support@profitbooks.net"
     bcc="Harshal Katre <harshal@profitbooks.net>, Samatha <samatha@profitbooks.net>, Ravi Rana <ravi@profitbooks.net>, Mohit Mogha <mohit@profitbooks.net>, Naveen <naveen@profitbooks.net>"
     @subject=subject
     mail(:to => to_email, :bcc => bcc, :from => "\"#{@user.email}\"<support@profitbooks.net>" ,:reply_to =>"ProfitBooks Team <support@profitbooks.net>" , :subject=> subject)
  end

  def say_hi(user)
    @user = user
    email = @user.email
    mail(:to => 'ravindra@thenextwave.in',:from => "support@profitbooks.net", :subject => "Hi user ?",:reply_to=> "support@profitbooks.net")
  end

  def subscription_expiration(user, subscription)
    @user = user
    @subscription = subscription
    email = @user.email
    mail(:to => email, :bcc => "sales@profitbooks.net", :from => "support@profitbooks.net", :subject => "Subscription expiration reminder",:reply_to=> "support@profitbooks.net")
  end

  def login_one_month_ago(user)
    @user = user
    email = @user.email
    mail(:to => email, :bcc => "ravindra@thenextwave.in", :from => "support@profitbooks.net", :subject => "It's been a month since you last login",:reply_to=> "support@profitbooks.net")
  end

  def request_accepted(user, invitation_detail)
    @user = user
    @invitation_detail = invitation_detail
    email = @user.email
    mail(:to => email, :from => "\"#{@invitation_detail.email}\"<support@profitbooks.net>", :subject => "Auditor request accepted.",:reply_to=> @invitation_detail.email)
  end

  def request_declined(user, invitation_detail)
    @user = user
    @invitation_detail = invitation_detail
    email = @user.email
    mail(:to => email, :from => "\"#{@invitation_detail.email}\"<support@profitbooks.net>", :subject => "Auditor request declined.",:reply_to=> @invitation_detail.email)
  end

  def renewal_date_update(user, company)
    @user = user
    @company = company
    email = @user.email
    mail(:to => email, :bcc => "harshal@thenextwave.in, naveen@profitbooks.net,mohnish@thenextwave.in, support@profitbooks.net",
      :from=>"support@profitbooks.net", :subject =>"renewal date updated",:reply_to=>"support@profitbooks.net")
  end

  def plan_updated(user, company)
    @user = user
    @company = company
    email = @user.email
    mail(:to => email, :bcc => "harshal@thenextwave.in, naveen@profitbooks.net,mohnish@thenextwave.in, support@profitbooks.net",
      :from=>"support@profitbooks.net", :subject =>"Current plan updated",:reply_to=>"support@profitbooks.net")
  end

  def plan_converted_to_free(user, company)
    @user = user
    @company = company
    email = @user.email
    mail(:to => email, :bcc => "harshal@thenextwave.in, naveen@profitbooks.net,mohnish@thenextwave.in, support@profitbooks.net",
      :from=>"support@profitbooks.net", :subject =>"Current plan converted into free plan",:reply_to=>"support@profitbooks.net")
  end

  def payment_info(user, company, payment_transaction, billing_invoice)
    @user = user
    @company = company
    @payment_transaction = payment_transaction
    @billing_invoice = billing_invoice
    email = @company.users.first.email
    mail(:to => email, :bcc => "leads@thenextwave.in", :from => "support@profitbooks.net", :subject=> "Payment update from ProfitBooks", :reply_to=>"support@profitbooks.net" )
  end

  def leave_request_created(user, company, leave_request)
    @user = user
    @company = company
    @leave_request = leave_request
    requester_email = User.find(@leave_request.user_id).email
    approver_email = User.find(@leave_request.approved_by).email
    mail(:to => approver_email, :bcc => "#{requester_email}", :from => "support@profitbooks.net", :subject => "New leave request has been created", :reply_to=>"support@profitbooks.net")
  end

  def leave_request_approved(user, company, leave_request)
    @user = user
    @company = company
    @leave_request = leave_request
    requester_email = User.find(@leave_request.user_id).email
    approver_email =  User.find(@leave_request.approved_by).email
    mail(:to => requester_email, :bcc => "#{approver_email}",
      :from => "support@profitbooks.net", :subject => "Your leave request has been approved", :reply_to=>"support@profitbooks.net")
  end

  def leave_request_rejected(user, company, leave_request)
    @user = user
    @company = company
    @leave_request = leave_request
    email = @company.users.first.email
    requester_email = User.find(@leave_request.user_id).email
    approver_email =  User.find(@leave_request.approved_by).email
    mail(:to => requester_email, :bcc => "#{approver_email}" , :from => "support@profitbooks.net", :subject => "Your leave request has been rejected",:reply_to=>"support@profitbooks.net")
  end

  # PBreferral to a friend
  def refer_pb(pbreferral)
    @pbreferral = pbreferral
    from_email = "#{User.find(@pbreferral.invited_by).email}"
    mail(:to => @pbreferral.email, :bcc=>"support@profitbooks.net", :from=> "support@profitbooks.net",
      :subject =>"#{User.find(@pbreferral.invited_by).first_name} #{User.find(@pbreferral.invited_by).last_name} has suggested to try ProfitBooks",:reply_to=>"support@profitbooks.net")
  end

  #REferral accepted
  def referral_accepted(pbreferral)
    @pbreferral = pbreferral
    email = "#{User.find(@pbreferral.invited_by).email}"
    mail(:to => email, :bcc=>"support@profitbooks.net", :from=> "support@profitbooks.net", :subject =>"#{@pbreferral.name} has registered with ProfitBooks",:reply_to=>"support@profitbooks.net")
  end

  #referral paid
  def referral_paid(pbreferral)
    @pbreferral = pbreferral
    email = "#{User.find(@pbreferral.invited_by).email}"
    mail(:to => email, :bcc=>"support@profitbooks.net", :from=> "support@profitbooks.net", :subject =>"Great News! #{@pbreferral.name} has subscribed to ProfitBooks",:reply_to=>"support@profitbooks.net")
  end

 def payment_received(file, invoice, current_company, current_user, subject, text, to_email)

  mail(:to => to_email, :bcc => "rohit@thenextwave.in",
      :from=>"support@profitbooks.net", :subject =>"Payment Received for")
 end

 #This email is sent to ProfitBooks Support if any user asks for a demo via the logout feedback form
 #Author: Ashish Wadekar
 #Date: 27th December 2016
 def customer_demo_request(current_user, company, comment)
    @user = current_user
    @company = company
    bcc = "Harshal Katre <harshal@profitbooks.net>, Samatha <samatha@profitbooks.net>, Ravi Rana <ravi@profitbooks.net>, Mohit Mogha <mohit@profitbooks.net>, Naveen <naveen@profitbooks.net>"
    @feedback = "Feedback provided:
    #{comment}." unless comment.blank?
    mail(:to => "support@profitbooks.net",:from => "support@profitbooks.net", :subject => "#{@user.full_name}  has requested for demo.",:reply_to => "support@profitbooks.net")
 end
end
