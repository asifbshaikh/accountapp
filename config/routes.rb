require 'sidekiq/web'
Profitnext::Application.routes.draw do

  get "gstr2as/upload"
  resources :gstr2as

  get "invoice_report/index"
  

  get "gstr2_filing/fetch_data" 
  get "gstr2_filing/upload"
  post "gstr2_filing/submit_otp"
  get "gstr2_filing/processing"
  get "gstr2_filing/verify"
  post "gstr2_filing/update_gross_values"
  get "gstr2_filing/summary" 
  get "gstr2_filing/fetch_gstr2a_b2b"
  resources :gstr2_filing
  
  get "product_catalog/index"
  get "gstr1_summaries/fetch"
  get "gstr1_summaries/processing"
  resources :gstr1_summaries

  get "gst_debit_notes/allocate"
  post "gst_debit_notes/create_allocation"
  post "gst_debit_notes/email_gst_debit_note"
  get "gst_debit_notes/remove_allocation"
  resources :gst_debit_notes

  get "gst_authorizer/new"
  post "gst_authorizer/create"

  resources :receipt_advances
  get "gstr_advance_receipts/create_gstr_advance_receipt_email"
  post "gstr_advance_receipts/email_gstr_advance_receipt"
  get "gstr_advance_receipts/desc_cost"
    #get "gstr_advance_receipts/fetch_line_items"
    get "gstr_advance_receipts/allocate"  
    #get "gstr_advance_receipts/receipt_advance"
    get "gstr_advance_receipts/remove_line_item"
    get "gstr_advance_receipts/customer_address"
    get "gstr_advance_receipts/gstr_advance_receipt_line_items"
    get "gstr_advance_receipts/add_row"
    get "gstr_advance_receipts/add_tax_row"
    get "gstr_advance_receipts/add_shipping_row"
    resources :gstr_advance_receipts

    get "gst_authorizer/show"

    resources :login_requests



    resources :gstr_one

    resources :gst_returns

    get "gst_credit_notes/allocate"
    get "gst_credit_notes/remove_allocation"
    post "gst_credit_notes/create_allocation"
    resources :gst_credit_notes

    resources :gstr3b_reports

    get "gstr_advance_payments/gstr_advance_payment_line_items"
    get "gstr_advance_payments/desc_cost"
    get "gstr_advance_payments/customer_address"
    get "gstr_advance_payments/remove_line_item"
    get "gstr_advance_payments/add_row"
    get "gstr_advance_payments/add_tax_row"
    get "gstr_advance_payments/add_shipping_row"
  #get "gstr_advance_payments/fetch_line_items"
  get "gstr_advance_payments/allocate"   

  

  get "purchase_advances/allocate" 
  resources :purchase_advances

  post "gstr_advance_payments/create_allocation"
  resources :gstr_advance_payments

  resources :invoice_attachments

  resources :payroll_settings

  resources :purchase_attachments

  get "webhook/payment_callback" => "webhook#payment_callback"

  post "webhook/cashfree_callback" => "webhook#cashfree_callback"

  get "purchase_settlement/index"

  get "inventory_statements/stock_statement"

  get "inventory_statements/product_statement"

  get "credit_expense_reports/index"

  get "invoice_returns/remove_line_item"
  resources :invoice_returns

  resources :purchase_return_line_items
  get "purchase_returns/remove_line_item"
  resources :purchase_returns

  get "vendor_imports/preview"
  post "vendor_imports/upload"
  get "vendor_imports/delete_file"
  get "vendor_imports/check_file_status"
  get "vendor_imports/import_preview"
  resources :vendor_imports

  get "customer_imports/preview"
  post "customer_imports/upload"
  get "customer_imports/delete_file"
  get "customer_imports/check_file_status"
  get "customer_imports/import_preview"
  resources :customer_imports

  get "journal_imports/preview"
  post "journal_imports/upload"
  get "journal_imports/delete_file"
  get "journal_imports/check_file_status"
  get "journal_imports/import_preview"
  resources :journal_imports

  get "product_imports/preview"
  post "product_imports/upload"
  get "product_imports/delete_file"
  get "product_imports/check_file_status"
  get "product_imports/import_preview"
  resources :product_imports

  get "product_updates/index"

  get "invoice_settlement/index"
  get "sales_order_reports/customer_wise_so"
  get "sales_order_reports/product_wise_so"
  get "sales_order_reports/pending_invoices_for_dc"

  get "bank_statements/file_import"
  get "bank_statements/import"
  get "bank_statements/statement"
  get "bank_statements/statement_delete"
  get "bank_statements/match_transaction"
  post "bank_statements/select_transaction"
  get "bank_statements/create_receipt"
  get "bank_statements/create_payment"
  get "bank_statements/payment_mode"
  get "bank_statements/create_other_income"
  get "bank_statements/create_expense"
  get "bank_statements/download"
  get "bank_statements/report"
  resources :bank_statements
  get "gain_or_loss_report/index"

  get "gain_or_loss_report/currency_wise"

  get "gain_or_loss_report/customer_wise"


  resources :pbreferrals

  get "delivery_challans/get_product_batches"

  get "payroll_execution_jobs/processing"
  resources :payroll_execution_jobs


  resources :delivery_challans

  get "sales_orders/add_shipping_row"
  get "sales_orders/remove_shipping_item"
  get "sales_orders/inventory_order"
  get "sales_orders/cancel_order"
  get "sales_orders/add_account"
  get "sales_orders/create_account"
  get "sales_orders/add_row"
  get "sales_orders/create_customer"
  get "sales_orders/remove_line_item"
  get "sales_orders/desc_cost"
  resources :sales_orders

  post "customer_statements/email_customer_statement"
  get "customer_statements/index"

  resources :voucher_settings
  resources :voucher_titles
  resources :user_informations
  resources :user_salary_details

  post "vendors/address"
  resources :vendors

  post "customers/address"
  resources :customers

  resources :webinars
  resources :tds_payment_vouchers
  get "tds_payment_vouchers/payment_mode"

  get "banking/index"

  get "banking/new"

  resources :labels

  put "product_settings/update_level_caption"
  resources :product_settings

  resources :inventory_settings

  resources :company_assets

  get "salary_structure_histories/index"
  get "salary_structure_histories/show"
  resources :salary_structure_histories

  get "blog/index"
  match "/blog/:id" => "blog#show", :via => "get"

  get "stock_movement/index"

  resources :blog_categories do
    resources :blog_posts, :controller => :blog
  end


  get "product_wise_stock/index"

  get "warehouse_wise_stock/index"
  get "warehouse_wise_stock/inventory_valuation"

  get "duties_and_taxes/show_modal"
  get "duties_and_taxes/index"
  get "duties_and_taxes/show"
  get "duties_and_taxes/new"
  get "duties_and_taxes/edit"
  get "duties_and_taxes/add_row"
  get "duties_and_taxes/report"
  get "duties_and_taxes/vat_report"
  post "duties_and_taxes/create"
  delete "duties_and_taxes/destroy"
  get "duties_and_taxes/tax_report"

  get "low_stock/index"

  get "stock_wastage_register/index"

  resources :stock_wastage_line_items

  get "stock_wastage_vouchers/select_product"
  get "stock_wastage_vouchers/add_row"
  get "stock_wastage_vouchers/remove_line_item"
  get "stock_wastage_vouchers/get_product_batches"
  resources :stock_wastage_vouchers

  resources :branches

  post "invoice_settings/change_template"
  post "invoice_settings/instamojo_settings"
  post "invoice_settings/cashfree_settings"
  post "webhook/payment_callback"
  post "invoice_settings/template_margin"


  resources :invoice_settings

  #new reports routes
  get "sales_reports/sales_by_customer"
  get "sales_reports/sales_by_item"
#-------------------------------------#
get "custom_fields/custom_field_report"
get "custom_fields/show"
resources :custom_fields

get "projects/mark_complete"
get "projects/ongoing_project"
get "projects/completed_project"
resources :projects

get "my_organisation/policy_document"
get "my_organisation/holiday_list"
get "my_organisation/announcement"
get "my_organisation/index"

#test route for zendesk login

match "zendesk/authorize" => "zendesk_auth#authorize", :as => "zendesk/authorize", :via => "get"
match "zendesk/logout" => "zendesk_auth#logout", :as => "zendesk/logout", :via => "get"
resources :zendesk_auth

#-----------------------#
get "leave_approval/update"

get "leave_approval/index"

get "leave_approval/show"

get "leave_approval/delete"

get "leave_approval/approve"

post "leave_approval/reject_leave"

resources :leave_approval
get "plan_properties/access_permition"
resources :plan_properties

get "billing_history/index"

get "billing_history/show"
get "login/switch_company"

resources :subscription_histories

resources :add_description_to_plans

get "billing/index"
get "billing/plan_details"
get "billing/foreign_index"
get "billing/apply_coupon"
get "billing/show"
get "billing/get_coupon"
post "billing/paymentresponse"
post "billing/upgrade"
resources :invitation_details

get "/client_invitations/create"
get "/client_invitations/rejected_client"
post "/client_invitations/destroy"
resources :client_invitations

get "auditor_login/forgot_pass"
post "auditor_login/check_password"
get "auditor_login/decline_request"
get "auditor_login/index"
post "auditor_login/authenticate"
get "auditor_login/accept_request"
post "auditor_login/accept_request"
get "auditor_login/proceed_request"
post "auditor_login/switch"
get "auditor_login/switch"
post "auditor_login/client_invitation_page"

get "auditors/change_password"
post "auditors/pass_update"
post "auditors/add_auditor"
post "auditors/soft_delete"
get "auditors/resend_invitation"
get "auditors/invite_auditor"
post "auditors/invite_auditor"
resources :auditors

  #---------------------------------------pbservices---------------------------
  match "pbservices/mail_request", :controller => 'pbservices', :action => 'mail_request'
  resources :pbservices

  #----------------------------------------------------------------------------
  get "db/dropbox_intro"
  get "db/index"

  get "email/new"

  get "payroll_details/index"

  get "payroll_details/payroll_run"
  get "payroll_details/user_profile"

  get "attendances/update_payroll_execution_detail"
  post "attendances/update_payroll_execution"
  get "attendances/add_row"
  get "attendances/remove_line_item"
  get "attendances/add_variable_payhead_detail"
  post "attendances/create_variable_payhead_detail"
  post "attendances/process_payroll"
  get "attendances/result"
  #------------------------------------- Payroll workers related routes -------------------------------------------
  match "attendances/finalize", :controller => 'attendances', :action => 'finalize'
  match "attendances/payroll_finalize", :controller => 'attendances', :action => 'payroll_finalize'
  match "attendances/discard", :controller => 'attendances', :action => 'discard'
  match "attendances/payroll_discard", :controller => 'attendances', :action => 'payroll_discard'
  #-----------------------------------------------------------------------------------------------------------------
  resources :attendances

  resources :posts do
    resources :comments
  end

  get "process_payrolls/month_view"
  get "process_payrolls/request_payroll"
  resources :process_payrolls

  get "process_payments/index"
 #-----------------------------------Home routes start------------------------------------
 #----------------------------------------------------------------------------------------
 get "home/common_questions"
 get "home/benefits_for_accountant_and_outsoursing_firms"
 get "home/accounting_software_features"
 get "home/user_feedback"
 get "home/index"
 get "home/accountant"
 get "home/sales"
 get "home/international_pricing"
 get "home/sitemap"
 get "home/features"
 get "home/pricing"
 get "home/foreign_pricing"
 get "home/faq"
 get "home/contact"
 get "home/new_contact"
 get "home/privacy_policy"
 get "home/terms_of_service"
 get "home/thanks_for_register"
 get "home/features_accounting"
 get "home/features_managers"
 get "home/features_payroll"
 get "home/features_team"
 get "home/accountant"
 get "home/sales"
 get "home/logged_out"
 #get "home/email_verified"
 #-----------------------------------Home routes end--------------------------------------
 #----------------------------------------------------------------------------------------

 #-----------------------------------Login/Signup routes start----------------------------
 #----------------------------------------------------------------------------------------
 get "signup/index"
 get "signup/new"
 get "signup/global_pricing"
 post "signup/create"
 post "signup/create_global"

 get "login/chrome_login"
 get "login/session_timeout"
 get "login/email_verify"
 get "login/resend_verification_email"
 get "login/index"
 get "login/convert"
 get "login/forgot_pass"
 post "login/check_password"
 get "login/signout"
 post "login/authenticate"
 get "login/logout_feedback"
 post "login/feedback_update"

  #-----------------------------------Login/signup routes end------------------------------
  #----------------------------------------------------------------------------------------

  #-----------------------------------Commen tools routes Start-----------------------------
  #-----------------------------------------------------------------------------------------

  #(1)Messages routes
  match "messages/sent" => "messages#sent", :as => "messages/sent", :via => "get"
  match "messages/draft" => "messages#draft", :as => "messages/draft", :via => "get"
  get "messages/permanent_delete"
  get "messages/notification"
  resources :messages

  #(2)Notes routes
  get"notes/tag"
  get"notes/deleted_notes"
  resources :notes

  #(3)Tasks routes
  get "tasks/mark_complete"
  get "tasks/closed"
  get "tasks/this_month"
  get "tasks/this_week"
  get "tasks/today"
  get "tasks/add_project"
  resources :tasks

  #(4)Documents routes
  #for browsing a folder
  match "browse/:folder_id" => "documents#browse", :as => "browse"

  #for creating folders insiide another folder
  match "browse/:folder_id/new_folder" => "folders#new", :as => "new_sub_folder"

  #for uploading files to folders
  match "browse/:folder_id/new_file" => "myfiles#new", :as => "new_sub_file"

  #for renaming a folder
  match "browse/:folder_id/rename" => "folders#edit", :as => "rename_folder"
  resources :folders

  #this route is for file downloads
  match "myfiles/get/:id" => "myfiles#get", :as => "download_file"
  resources :myfiles

  #for sharing the folder
  match "documents/share" => "documents#share", :as =>"share"
  post "documents/create"
  get "documents/index"


  #(5)Other commen tools
  resources :feedbacks
  get "supports/permanent_delete"
  post "supports/close_ticket"
  resources :supports
  resources :helps
  resources :feedbacks

  #(6) confused where to put these routes hence put here
  get "tags/index"
  get "tags/show"

  get "email_template/emailtemplate"
  get "email_actions/email_template"
  resources :email_actions

   #(7)admin controller routes
#  match "admin/admin" => "admin#admin_tr", :as => "admin"
#  get "admin/company_details"
#  get "admin/company_data"
  # get "admin/_company"
#  get "admin/_reports"
#  get "admin/_billing"
#  get "admin/company_this_week"
#  get "admin/company_this_year"
#  get "admin/company_this_month"
#  get "admin/company_closed"
#   get "admin/users_details"
#  get "admin/users_last_month"
#  get "admin/users_last3_month"
#  get "admin/users_last6_month"
#  get "admin/users_last9_month"
#  get "admin/users_last12_month"
#  resources :admin

  #-----------------------------------Commen tools routes end------------------------------
  #----------------------------------------------------------------------------------------

  #--------------------------Accounting routes start.--------------------------------------
  #----------------------------------------------------------------------------------------

  #(1)accounting dashboard
  get "dashboard/reports"
  get "dashboard/index"
  post "dashboard/schedule_demo"
  get "dashboard/setup"
  get "dashboard/create_account"
  get "dashboard/add_account"
  get "dashboard/upgrade"
  get "dashboard/upgrade_plan"
  get "dashboard/set_session"
  post "dashboard/setup_update"
  get "dashboard/final_setup"
  post "dashboard/final_setup_update"
  #get "dashboard/account_management"
  #post "dashboard/account_management_update"
  resources :dashboards

  #(2)Income Menu routes

  #(a)Invoice routes
  get "invoices/customer_details"
  post "invoices/update_address"
  get "invoices/batch_number_details"
  get "invoices/add_warehouse_detail_row"
  get "invoices/remove_warehouse_detail_row"
  get "invoices/created_from_sales_order"
  post "invoices/settle"
  post "invoices/add_payment"
  get "invoices/take_batch_quantity"
  get "invoices/batch_details"
  get "invoices/customer_pricing"
  get "invoices/start_recursion"
  get "invoices/stop_recursion"
  get "invoices/recursive_invoices"
  get "invoices/copy_invoice"
  get "invoices/converted_from_estimate"
  get "invoices/set_tax"
  get "invoices/add_product"
  get "invoices/create_custom_field"
  get "invoices/add_custom_field"
  get "invoices/search_invoice"
  get "invoices/create_invoice_email"
  post "invoices/email_invoice"
  post "invoices/instamojo_payment"
  post "invoices/cashfree_payment"
  get "invoices/add_account"
  get "invoices/create_account"
  get "invoices/take_warehouse_quantity"
  get "invoices/select_warehouse"
  get "invoices/desc_cost"
  get "invoices/add_shipping_row"
  get "invoices/add_time_row"
  get "invoices/add_item"
  get "invoices/add_tax"
  get "invoices/create_tax"
  get "invoices/create_item"
  get "invoices/add_customer"
  get "invoices/create_customer"
  get "invoices/get_quantity"
  get "invoices/remove_shipping_item"
  get "invoices/remove_time_item"
  get "invoices/remove_tax_item"
  get "invoices/item_from_warehouses"
  get "invoices/add_tax_row"
  get "invoices/add_row"
  get "invoices/remove_line_item"
  get "invoices/restore_invoice"
  get "invoices/permanent_delete_invoice"
  match "invoices/deleted_invoice" => "invoices#deleted_invoice", :as => "invoices/deleted_invoice", :via => "get"
  match "invoices/open" => "invoices#open", :as => "invoices/open", :via => "get"
  match "invoices/closed" => "invoices#closed", :as => "invoices/closed", :via => "get"
  match "invoices/draft" => "invoices#draft", :as => "invoices/draft", :via => "get"
  match "invoices/cash_invoice" => "invoices#cash_invoice", :as => "invoices/cash_invoice", :via => "get"
  match "invoices/time_invoice" => "invoices#time_invoice", :as => "invoices/time_invoice", :via => "get"
  resources :invoices do
    get :autocomplete_account_name, :on => :collection
  end

  #(b)receipt_voucher routes
  get "receipt_vouchers/customer_unpaid_invoices"
  get "receipt_vouchers/customer_invoices"
  get "receipt_vouchers/create_email"
  post "receipt_vouchers/email_receipt_voucher"
  get "receipt_vouchers/permanent_delete_receipt_voucher"
  get "receipt_vouchers/restore_receipt_voucher"
  get "receipt_vouchers/payment_mode"
  get "receipt_vouchers/search_invoice"
  get "receipt_vouchers/add_deposit_to_account"
  get "receipt_vouchers/create_account"
  get "receipt_vouchers/account_partial"
  get "receipt_vouchers/allocate"
  match "receipt_vouchers/deleted_receipt_voucher" => "receipt_vouchers#deleted_receipt_voucher",
  :as => "receipt_vouchers/deleted_receipt_voucher", :via => "get"

  get "gstr1_filings/fetch_data" 
  get "gstr1_filings/upload"
  post "gstr1_filings/request_filing_otp"
  get "gstr1_filings/verify"
  get "gstr1_filings/update"
  get "gstr1_filings/request_gross_values"
  post "gstr1_filings/update_gross_values"
  post "gstr1_filings/submit_otp"
  get "gstr1_filings/processing"
  resources :gstr1_filings


  resources :receipt_vouchers

 #(c)Estimates routes
 get "estimates/customer_details"
 get "estimates/convert_to_so"
 get "estimates/create_estimate_email"
 post "estimates/email_estimate"
 get "estimates/add_account"
 get "estimates/create_account"
 get "estimates/remove_tax_item"
 get "estimates/remove_shipping_item"
 get "estimates/add_shipping_row"
 get "estimates/add_tax_row"
 get "estimates/add_row"
 get "estimates/add_item"
 get "estimates/add_tax"
 get "estimates/create_tax"
 get "estimates/create_item"
 get "estimates/add_customer"
 get "estimates/create_customer"
 get "estimates/remove_line_item"
 get "estimates/convert_to_invoice"
 get "estimates/permanent_delete_estimate"
 get "estimates/restore_estimate"
 get "estimates/desc_cost"
 match "estimates/deleted_estimate" => "estimates#deleted_estimate", :as => "estimates/deleted_estimate", :via => "get"
 resources :estimates

  #(d)Other income routes
  get "income_vouchers/add_account"
  get "income_vouchers/create_account"
  get "income_vouchers/permanent_delete_other_income"
  get "income_vouchers/restore_other_income"
  get "income_vouchers/payment_mode"
  get "income_vouchers/payment_mode_edit"

#seprate controller added
get "banking/index"
get "banking/new"
get "banking/new_withdrawal"
get "banking/new_deposit"
get "banking/new_transfer"
#------------------------------------
match "income_vouchers/deleted_other_income" => "income_vouchers#deleted_other_income",
:as => "income_vouchers/deleted_other_income", :via => "get"
resources :income_vouchers do
  get :autocomplete_account_name, :on => :collection
end

  #-----Income Menu routes End-----:

  #(3)Expense Menu routes Start-----:

  #(a)Expense routes
  post "expenses/update_itc_details"
  get "expenses/account_select"
  get "expenses/copy_expense"
  get "expenses/remove_tax_item"
  get "expenses/add_tax_row"
  get "expenses/add_row"
  get "expenses/add_account"
  get "expenses/create_account"
  get "expenses/add_to_row"
  get "expenses/remove_expense_line_item"
  get "expenses/remove_paid_line_item"
  get "expenses/permanent_delete_expense"
  get "expenses/restore_expense"
  get "expenses_report/expenses_report"
  post "expenses_report/expenses_report"
  match "expenses/deleted_expense" => "expenses#deleted_expense", :as => "expenses/deleted_expense", :via => "get"
  #this route is for file downloads
  match "expenses/get/:id" => "expenses#get", :as => "download_exp_file"
  resources :expenses

  #(b)Purchase routes
  post "purchases/settle"
  post "purchases/update_itc_details"
  get "purchases/customer_details"
  get "purchases/remove_warehouse_detail_row"
  get "purchases/add_warehouse_detail_row"
  get "purchases/po_to_purchase"
  get "purchases/add_batch_row"
  get "purchases/add_other_charge_row"
  get "purchases/remove_other_charge_item"
  get "purchases/paid"
  get "purchases/unpaid"
  get "purchases/take_warehouse_quantity"
  get "purchases/select_warehouse"
  get "purchases/remove_tax_item"
  get "purchases/remove_discount_item"
  get "purchases/add_tax_row"
  get "purchases/add_discount_row"
  get "purchases/add_row"
  get "purchases/add_account"
  get "purchases/create_account"
  get "purchases/remove_line_item"
  get "purchases/permanent_delete_purchase"
  get "purchases/restore_purchase"
  get "purchases/desc_cost"
  post "purchases/delete_file/:id" => "purchases#delete_file", :as => "purchases/delete_file", :via => "post"
  match "purchases/voucher_details/:id" => "purchases#voucher_details", :as => "purchases/voucher_details", :via => "get"
  match "purchases/deleted_purchase" => "purchases#deleted_purchase", :as => "purchases/deleted_purchase", :via => "get"
  #this route is for file downloads
  match "purchases/get/:id" => "purchases#get", :as => "download_purchase_file"
  resources :purchases


  resources :purchase_attachment
  get "purchase_attachments/header"
  get "purchase_attachments/show"
  get "purchases/purchases/doc_footer"
  get "purchases/purchase_attachments"
  post "purchase_attachments/purchase_attachments"

  post "purchase_attachments/new"
  get "purchases/shared_doc"

  get "invoice_attachments/header"
  get "invoice_attachments/show"
  post "invoice_attachments/new"
  get "invoice/shared_doc"




  #(c)Purchase orders routes
  get "purchase_orders/customer_details"
  get "purchase_orders/add_other_charge_row"
  get "purchase_orders/remove_other_charge_item"
  post "purchase_orders/email_purchase_order"
  get "purchase_orders/remove_tax_item"
  get "purchase_orders/add_tax_row"
  get "purchase_orders/add_row"
  get "purchase_orders/add_account"
  get "purchase_orders/create_account"
  get "purchase_orders/remove_line_item"
  get "purchase_orders/open"
  get "purchase_orders/closed"
  get "purchase_orders/draft"
  get "purchase_orders/desc_cost"
  get "purchase_orders/permanent_delete_purchase_order"
  get "purchase_orders/restore_purchase_order"
  match "purchase_orders/deleted_purchase_order" => "purchase_orders#deleted_purchase_order",
  :as => "purchase_orders/deleted_purchase_order", :via => "get"
  #this route is for file downloads
  match "purchase_orders/get/:id" => "purchase_orders#get", :as => "download_purchase_order_file"
  resources :purchase_orders

  #(d)Make payments routes
  get "payment_vouchers/allocate"
  get "payment_vouchers/vendor_unpaid_vouchers"
  get "payment_vouchers/load_form"
  get "payment_vouchers/get_vendor_vouchers"
  get "payment_vouchers/search_purchase"
  get "payment_vouchers/permanent_delete_payment_voucher"
  get "payment_vouchers/restore_payment_voucher"
  get "payment_vouchers/payment_mode"
  get "payment_vouchers/add_account"
  get "payment_vouchers/create_account"
  match "payment_vouchers/deleted_payment_voucher" => "payment_vouchers#deleted_payment_voucher",
  :as => "payment_vouchers/deleted_payment_voucher", :via => "get"
  #this route is for file downloads
  match "payment_vouchers/get/:id" => "payment_vouchers#get", :as => "download_payment_file"
  resources :payment_vouchers

  #-----Expense Menu routes End-----:

  #(4)Banking Menu routes Start-----:

  #(a)withdrawal routes
  get "withdrawals/add_account"
  get "withdrawals/create_account"
  get "withdrawals/permanent_delete_withdrawal"
  get "withdrawals/restore_withdrawal"
  get "withdrawals/deleted_withdrawal"
  resources :withdrawals

  #(b)deposit routes
  get "deposits/add_account"
  get "deposits/create_account"
  get "deposits/permanent_delete_deposit"
  get "deposits/restore_deposit"
  get "deposits/deleted_deposit"
  resources :deposits

  #(c)transfer cash routes
  get "transfer_cashes/add_account"
  get "transfer_cashes/create_account"
  get "transfer_cashes/permanent_delete_transfer_history"
  get "transfer_cashes/restore_transfer_history"
  get "transfer_cashes/deleted_transfer_history"
  resources :transfer_cashes

  #(d)Bank reconciliation route
  #get "bank_reconciliation/update_multiple"
  get "bank_reconciliation/reconcile"

  #-----Banking Menu routes End-----:

  #(5)Journal Menu routes Start-----:

  #(a)journals routes
  get "journals/permanent_delete_journal"
  get "journals/restore_journal"
  get "journals/deleted_journal"
  get "journals/add_row"
  get "journals/add_account"
  get "journals/create_account"
  get "journals/add_to_row"
  get "journals/remove_line_item"
  get "journals/remove_to_line_item"
  resources :journals

  #(b)Debit note route
  get "debit_notes/permanent_delete_debit_note"
  get "debit_notes/restore_debit_note"
  get "debit_notes/deleted_debit_note"
  get "debit_notes/add_account"
  get "debit_notes/create_account"
  get "debit_notes/allocate"
  get "debit_notes/remove_allocation"
  post "debit_notes/create_allocation"
  resources :debit_notes
  #(c)Credit note route
  get "credit_notes/permanent_delete_credit_note"
  get "credit_notes/restore_credit_note"
  get "credit_notes/deleted_credit_note"
  get "credit_notes/add_account"
  get "credit_notes/create_account"
  get "credit_notes/allocate"
  get "credit_notes/remove_allocation"
  post "credit_notes/create_allocation"
  resources :credit_notes
  #(d)Reimbursement note route
  get "reimbursement_notes/permanent_delete_reimbursement_note"
  get "reimbursement_notes/restore_reimbursement_note"
  get "reimbursement_notes/deleted_reimbursement_note"
  get "reimbursement_notes/add_account"
  get "reimbursement_notes/create_account"
  get "reimbursement_notes/remove_line_item"
  get "reimbursement_notes/add_row"
  post "reimbursement_notes/email_reimbursement_note"
  resources :reimbursement_notes

  get "reimbursement_note_attachments/header"
  get "reimbursement_note_attachments/show"
  get "reimbursement_notes/reimbursement_notes/doc_footer"
  get "reimbursement_notes/reimbursement_note_attachments"
  post "reimbursement_note_attachments/reimbursement_note_attachments"
  post "reimbursement_note_attachments/new"
  get "reimbursement_notes/shared_doc"
  resources :reimbursement_note_attachments

  #(e)reimbursement_voucher routes
  get "reimbursement_vouchers/get_reimbursement_notes_for_account"
  get "reimbursement_vouchers/customer_unpaid_invoices"
  get "reimbursement_vouchers/customer_invoices"
  get "reimbursement_vouchers/create_email"
  post "reimbursement_vouchers/email_reimbursement_voucher"
  get "reimbursement_vouchers/permanent_delete_reimbursement_voucher"
  get "reimbursement_vouchers/restore_reimbursement_voucher"
  get "reimbursement_vouchers/payment_mode"
  get "reimbursement_vouchers/search_invoice"
  get "reimbursement_vouchers/add_deposit_to_account"
  get "reimbursement_vouchers/create_account"
  get "reimbursement_vouchers/account_partial"
  get "reimbursement_vouchers/allocate"
  match "reimbursement_vouchers/deleted_reimbursement_voucher" => "reimbursement_vouchers#deleted_reimbursement_voucher",
  :as => "reimbursement_vouchers/deleted_reimbursement_voucher", :via => "get"
  resources :reimbursement_vouchers
  #(f)Simple accounting routes
  get "saccountings/permanent_delete_saccounting"
  get "saccountings/restore_saccounting"
  get "saccountings/deleted_saccounting"
  get "saccountings/add_row"
  get "saccountings/add_account"
  get "saccountings/create_account"
  get "saccountings/add_to_row"
  get "saccountings/remove_line_item"
  get "saccountings/remove_to_line_item"
  resources :saccountings

  #-----Journal Menu routes End-----:

  #(6)Inventory Menu routes Start-----:

  #(a)products route
  get "products/select_warehouse"
  get "products/take_warehouse_quantity"
  get "products/sales_items"
  get "products/purchase_items"
  get "products/reseller_items"
  get "products/all_items"
  get "products/add_row"
  post "products/record_batch_warehouse_details"
  post "products/record_batch_details"
  post "products/upload"
  get "products/product_import"
  get "products/import_preview"
  get "products/manage_stock"
  get "products/load_hsn_code"
  resources :products
  resources :sales_items, :controller => 'products', :type => 'SalesItem'
  resources :purchase_items, :controller => 'products', :type => 'PurchaseItem'
  resources :reseller_items, :controller => 'products', :type => 'ResellerItem'
  #(b)warehoude route
  get "warehouses/new_batch_detail"
  get "warehouses/add_batch_row"
  post "warehouses/record_batch_warehouse_details"
  resources :warehouses
  #(c)stock receipt vouchers routes
  get "stock_receipt_vouchers/add_row"
  get "stock_receipt_vouchers/remove_line_item"
  get "stock_receipt_vouchers/batch_number_details"
  resources :stock_receipt_vouchers
  #(d)stock issue vouchers routes
  get "stock_issue_vouchers/add_row"
  get "stock_issue_vouchers/remove_line_item"
  get "stock_issue_vouchers/get_product_batches"
  resources :stock_issue_vouchers
  # (e) stock transfer vouchers routes
  get "stock_transfer_vouchers/warehouse_wise_product"
  get "stock_transfer_vouchers/add_row"
  get "stock_transfer_vouchers/remove_line_item"
  get "stock_transfer_vouchers/get_product_batches"
  resources :stock_transfer_vouchers


  #-----Inventory Menu routes End-----:

  #(7)Accounting reports route start------:

  #(1) Final Accounts reports
  #(a)Balance Sheet report routes
  get "vertical_balance_sheet/index"
  get "horizontal_balance_sheet/index"

  #(b)Profit and loss report routes
  get "vertical_profit_and_loss/index"
  get "horizontal_profit_and_loss/index"
  #(c)Trial balance report route
  get "trial_balance/group_summary_report"
  get "trial_balance/index"

  #(2) Accounts Books and register reports
  get "account_books_and_registers/reports"
  get "bank_book/index"
  get "cash_book/index"
  get "credit_note_register/index"
  get "gst_credit_note_register/index"
  get "debit_note_register/index"
  get "gst_debit_note_register/index"
  get "journal_register/index"
  get "account_books_and_registers/ledger"
  get "bills_payable/index"
  get "bills_receivable/index"
  get "purchase_register/index"
  get "sales_register/index"
  get "sundry_creditor/index"
  get "debtor_aging/index"
  post "debtor_aging/index"

  #(3)Day book report
  get "daybook/index"

  #-----Accounting reports route end------:

  #(8)Setting Menu routes Start-----:
  #(a)Accounts route
  get "accounts/product_or_service_accounts"
  get "accounts/tax_accounts"
  get "accounts/add_account"
  get "accounts/create_account"
  get "accounts/vendor_accounts"
  get "accounts/customer_accounts"
  get "accounts/bank_accounts"
  get "accounts/account_partial"
  get "accounts/sundrydebtor_popup"
  get "accounts/add_row"
  get "accounts/invoices"
  get "accounts/estimates"
  get "accounts/receipt_vouchers"
  get "accounts/account_detail"
  get "accounts/purchases"
  get "accounts/purchase_orders"
  get "accounts/payment_vouchers"
  resources :accounts
  #(b)Account heads route
  resources :account_heads

  #(c)Settings route for company
  get "settings/create_title"
  get "settings/payroll"
  get "settings/inventory"
  get "settings/create_warehouse"
  get "settings/custom_field"
  get "settings/invoice_setting"
  get "settings/edit_logo"
  post "settings/update_logo"
  post "settings/freeze_year"
  get "settings/freeze_fin_year"
  post "settings/unfreeze_fin_year"
  get "settings/index"
  get "settings/show"
  get "settings/edit"
  get "settings/edit"
  post "settings/set_voucher_sequence"
  get "settings/customfield"
  post "settings/cashfree_file"
  get "settings/enable_gateway"
  get "settings/load_form"
  #this route is for file downloads
 # match "companies/get/:id" => "companies#get", :as => "download_company_logo"
 resources :companies
 resources :workstreams

  #(d)Confused for ledger routs therefor put here
  match "ledgers/deleted_ledger_entry" => "ledgers#deleted_ledger_entry", :as => "ledgers/deleted_ledger_entry", :via => "get"
  resources :ledgers do
   post :edit_multiple, :on => :collection
   put :update_multiple, :on => :collection
 end
  #-----Setting Menu routes End-----:

  #-------------------------Accounting routes end.------------------------------------------------
  #-----------------------------------------------------------------------------------------------

  #-------------------------Payroll routes start.-------------------------------------------------
  #-----------------------------------------------------------------------------------------------

  #(1)Payroll Dash board
  get "payroll_dashboard/index"

  #(2)Self Service menu routes
  #get "assets/my_asset"
  get "employee_profile/index"
  get "employee_goals/emp_goal"
  get "leave_requests/dashboard"
  get "leave_requests/my_leave_request"
  #(1)Messages routes
  match "leave_requests/pending_approval" => "leave_requests#pending_approval", :as => "leave_requests/pending_approval", :via => "get"
  match "leave_requests/approved" => "leave_requests#approved", :as => "leave_requests/approved", :via => "get"
  match "leave_requests/rejected" => "leave_requests#rejected", :as => "leave_requests/rejected", :via => "get"
  match "leave_requests/revoke" => "leave_requests#revoke", :as => "leave_requests/revoke", :via => "get"

  get "salary_slip/detail"
  get "salary_slip/index"

  #(3)Timesheets menu routes
  get "timesheets/report"
  get "timesheets/change_week"
  get "timesheets/add_row"
  get "timesheets/remove_line_item"
  get "timesheets/new_weekly"
  post "timesheets/create_weekly_timesheet"
  resources :timesheets # for timesheets tasks routes are in commen tools

  resources :leave_cards
  #(4)Forms menu routes
  resources :leave_requests

  #(5)Organigation menu routes

  #(a)Announcements
  get "organisation_announcements/announcement"

  #(b)Holiday List
  get "holidays/holiday_list"

  #(c)Policy documents
  #this route is for policy document file downloads
  match "policy_documents/get/:id" => "policy_documents#get", :as => "download"
  resources :policy_documents

  #(5)Administration Menu routes

  #(a)Performance Management routes
  resources :master_objectives
  resources :employee_goals

  #(b)Users routes
  get "users/salary_details"
  get "users/leave_detail"
  get "users/manage_payroll"
  get "users/delete_note"
  get "users/edit_avatar"
  post "users/update_avatar"
  post "users/basic_info"
  post "users/work_info"
  get "users/user_assets"
  get "users/personal_info"
  get "users/work_info"
  get "users/hello_user"
  get "user_settings/index"
  get "users/profile_image"
  get "users/my_profile"
  get "users/change_password"
  post "users/pass_update"
  get "users/reset_password"
  post "users/set_new_password"
  post "users/mail_new_user"
  post "users/restore_user"
  match 'users/mail_new_user', :controller => 'users', :action => 'mail_new_user'
  match 'users/restore_user', :controller => 'users', :action => 'restore_user'


  resources :users
  #match "/my_profile" => "users#my_profile", :as => :my_profile

  post "myprofile/set_new_password"
  # match 'myprofile/leave_detail', :controller => 'myprofile', :action => 'leave_detail'
  resources :myprofile

  #(c)Manage Salary Structures routes
  get "salary_structures/copy_salary_structure"
  get "salary_structures/add_payhead"
  get "salary_structures/create_payhead"
  get "salary_structures/add_row"
  get "salary_structures/remove_line_item"
  resources :salary_structures
  get "payheads/payroll_account"
  resources :payheads

  #(d)Organisation settings routes
  #resources :assets
  resources :departments
  resources :designations
  resources :holidays
  resources :leave_types
  resources :organisation_announcements

  #(6)Payroll Reports Route
  get "gratuity_report/index"
  get "income_tax_computation/index"
  get "income_tax_form_16/index"
  get "payment_advice/index"
  get "provident_fund_form5/index"
  get "tds_variance_report/index"
  get "employee_breakup/index"
  get "employee_breakup/breakup_for_employee"
  get "payroll_register/index"

  #(7)Reimbursement Reports Route
  get "reimbursement_reports/outstanding_report"

  #------------------------------------Payroll routes end--------------------------------------
  #--------------------------------------------------------------------------------------------

  #--------------------------------------------------------------------------------------------
  #-------------------------Routes not in use presently start----------------------------------

  #(1)Accounting routes not in use
  resources :record_expenses
  resources :debitnotes
  resources :creditnotes
  resources :estimate_line_items
  resources :payments
  resources :receive_cashes
  resources :finished_goods
  resources :issue_raw_materials
  resources :inventories
  resources :invoice_statuses
  # Accounting reports old route not in use now
  get "final_accounts/vertical_profit_and_loss_report"
  get "final_accounts/horizontal_profit_and_loss_report"
  get "final_accounts/horizontal_balance_sheet"
  get "final_accounts/vertical_balance_sheet"
  get "final_accounts/trial_balance_report"

  get "account_books_and_registers/bills_payable"
  get "account_books_and_registers/bills_receivable"
  get "account_books_and_registers/journal_register"
  get "account_books_and_registers/bank_book"
  get "account_books_and_registers/cash_book"
  get "account_books_and_registers/credit_note_register"
  get "account_books_and_registers/debit_note_register"
  get "account_books_and_registers/purchase_register"
  get "account_books_and_registers/sales_register"
  get "account_books_and_registers/sundry_creditor"


  #(2)Payroll routes not in use
  resources :employees
  resources :jobs
  resources :contacts
  resources :payhead_types
  resources :pay_grades
  #Payroll reports not in use now
  get "payroll_reports/salary_slip"
  get "payroll_reports/employee_profile"
  get "payroll_reports/payroll_register"
  get "payroll_reports/employee_breakup"
  get "payroll_reports/payment_advice"
  get "payroll_reports/gratuity_report"
  get "payroll_reports/provident_fund_form5"
  get "payroll_reports/income_tax_computation"
  get "payroll_reports/tds_variance_report"
  get "payroll_reports/income_tax_form16"
  get  "settings/enable_payslip_signatory"

  #----Routes Not in use end-----------------------------------------------------------------
  #------------------------------------------------------------------------------------------

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  ########################## Routes for admin module ##################################
  namespace :admin do
    get "webinar/index"
    resources :blog_posts

    resources :blog_categories

    # Directs /admin/products/* to Admin::ProductsController
    # (app/controllers/admin/products_controller.rb)

    match 'announcements/:id/hide'=> 'announcements#hide', :as=> 'hide_announcement', :via=> "get"
    resources :announcements

    get "billing_invoices/new"

    post "billing_invoices/create"

    get "billing_invoices/show"

    get "billing_invoices/index"
    get "billing_invoices/get_company"

    get "super_users/inactive_channel"
    get "super_users/active_channel"
    resources :super_users

    resources :channels
    resources :campaigns

    get "leads/add_channel"
    get "leads/add_campaign"
    get "leads/create_channel"
    get "leads/create_campaign"
    post "leads/add_activity"
    post "leads/update_activity"
    get "leads/delete_lead"
    get "leads/restore_lead"
    get "leads/convert_to_paid"
    get "leads/convert_to_trial"
    get "leads/activity_reports"
    get "leads/lead_reports"
    get "leads/todays_leads"
    get "leads/paid_leads"
    get "leads/unpaid_leads"
    get "leads/weeks_leads"
    get "leads/pending_leads"
    get "leads/deleted_leads"
    get "leads/lead_action"
    post "leads/send_email"
    get "leads/select_template"
    get "leads/time_consumed_by_activities"
    get "leads/channel_summary"
    get "leads/request_demo"
    get "leads/assign"
    get "leads/junk"
    get "leads/qualified"
    post "leads/change_user"
    post "leads/mark_lost"
    # post "leads/demo"
    resources :leads

    resources :workstreams

    get "dashboard/today"
       get "dashboard/past"
       get "dashboard/upcoming"
       resources :dashboard
       resources :customer_relationships
       resources :coupons

       get "email_templates/send_weekly_email"
       get "email_templates/weekly_email"
       get "email_templates/send_email"
       get "email_templates/send_bulk_email"
       get "email_templates/index"
       get "email_templates/new"
       get "email_templates/edit"
       get "email_templates/show"
       get "email_templates/repeat_send_mail"
       resources :email_templates

       get "contact_details/contacts"
       get "login/index"
       get "plans/index"
       post "plans/grant"
       get "plans/get_right"
       get "plans/get_role"
       get "login/signout"
       post "login/authenticate"
       get "supports/permanent_delete"
       post "supports/close_ticket"
       resources :supports

       get "companies/edit_logo"
       post "companies/update_logo"
       get "companies/expiring_this_week"
       get "companies/expiring_in_15_days"
       post "companies/upgrade_plan"
       get "companies/paid_companies"
       get "companies/update_renewal"
       post "companies/renew"
       post "companies/reset_user_password"
       get "companies/green"
       get "companies/amber"
       get "companies/red"
       get"companies/workstream"
       get"companies/resend_welcome_email"
       get"companies/this_week"
       get"companies/this_month"
       get"companies/this_year"
       get"companies/expiring_this_month"
       get"companies/company_closed"
       get"companies/paid_companies"
       get"companies/trial_companies"
       get"companies/report_charts"
       post"companies/update_followup"
       post"companies/add_activity"
       post"companies/send_email"
       get"companies/select_template"
       get"companies/activity_reports"
       get"companies/reports"
       get"companies/sales_by_user"
       get"companies/sales_cycle"
       get"companies/weekly_shedule"
       get"companies/task_delay_report"
       resources :companies
       get "users/users_last_month"
       get "users/users_last3_month"
       get "users/users_last6_month"
       get "users/users_last9_month"
       get "users/users_last12_month"
       resources :users
       resources :plans
       resources :profitbooks_workstreams do
         member do
          put 'publish'
          put 'archive'
        end
      end
       #Added Sidekiq Monitoring Web tool to admin
       #Author: Ashish Wadekar
       #Date: 23rd September 2016
       #------------Sidekiq Monitoring Tool route---------------#
       mount Sidekiq::Web => '/monitoring/sidekiq', constraints: lambda { |request| request.session['current_super_user_id'] == 1 || 2}
       #-------------------------- End -------------------------#
       #get "profitbooks_workstream/publish"
     end
  ########################## Routes for admin module ##################################
  #----------- Dropbox routes ------------#
  match 'db/authorize', :controller => 'db', :action => 'authorize'
  match 'db/upload', :controller => 'db', :action => 'upload'
  get "db/download"
  post "db/create_folder"
  get "db/create_folder"
  post "db/upload_file"
  get "db/delete_file"
  #----------- End -----------------------#

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "login#index"

# See how all your routes lay out with "rake routes"

# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id(.:format)))'
end
