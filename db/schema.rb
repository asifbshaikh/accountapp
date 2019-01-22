# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 201709051114260) do

  create_table "account_heads", :force => true do |t|
    t.integer  "company_id",                                          :null => false
    t.integer  "parent_id"
    t.string   "name",                                                :null => false
    t.string   "desc"
    t.string   "relevance",         :limit => 100
    t.integer  "created_by",                                          :null => false
    t.integer  "approved_by"
    t.boolean  "deleted",                          :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "erasable",                         :default => true
  end

  add_index "account_heads", ["company_id"], :name => "acc_head_comp_idx"

  create_table "account_histories", :force => true do |t|
    t.integer  "company_id",                                                        :null => false
    t.integer  "account_id",                                                        :null => false
    t.integer  "financial_year_id",                                                 :null => false
    t.decimal  "opening_balance",   :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "closing_balance",   :precision => 18, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.integer  "company_id",                                                          :null => false
    t.integer  "account_head_id",                                                     :null => false
    t.string   "name",                                                                :null => false
    t.integer  "accountable_id"
    t.string   "accountable_type"
    t.decimal  "opening_balance",   :precision => 18, :scale => 2, :default => 0.0
    t.integer  "created_by",                                                          :null => false
    t.integer  "approved_by"
    t.boolean  "deleted",                                          :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.integer  "customer_id"
    t.integer  "vendor_id"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "erasable",                                         :default => true
  end

  add_index "accounts", ["company_id", "name"], :name => "acc_comp_idx"
  add_index "accounts", ["customer_id"], :name => "acc_custid_idx"

  create_table "active_sessions", :force => true do |t|
    t.integer  "company_id",     :null => false
    t.integer  "gsp_id",         :null => false
    t.string   "auth_token"
    t.integer  "expiry"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "sek"
    t.string   "remote_user_ip"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "addresses", :force => true do |t|
    t.string  "address_line1"
    t.string  "address_line2"
    t.string  "city",             :limit => 100
    t.string  "state",            :limit => 100
    t.string  "country",          :limit => 100
    t.string  "postal_code",      :limit => 7
    t.integer "addressable_id"
    t.string  "addressable_type"
    t.integer "address_type",                    :default => 1
    t.string  "state_code"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "add_id_type_idx"

  create_table "announcements", :force => true do |t|
    t.integer  "company_id"
    t.integer  "plan_id"
    t.integer  "user_id"
    t.string   "subject"
    t.text     "message"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assets", :force => true do |t|
    t.integer  "company_id",    :null => false
    t.integer  "user_id",       :null => false
    t.string   "asset_tag"
    t.text     "description"
    t.date     "purchase_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assigned_to"
  end

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["user_id", "role_id"], :name => "assgn_userid_roleid_idx"

  create_table "attendances", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.date     "month"
    t.decimal  "days_present", :precision => 4, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "days_absent",  :precision => 4, :scale => 2, :default => 0.0
  end

  create_table "auditor_assignments", :force => true do |t|
    t.integer  "auditor_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auditors", :force => true do |t|
    t.string   "first_name",      :limit => 100, :null => false
    t.string   "last_name",       :limit => 100, :null => false
    t.string   "username",        :limit => 32,  :null => false
    t.string   "hashed_password",                :null => false
    t.string   "salt",                           :null => false
    t.boolean  "reset_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "bank_accounts", :force => true do |t|
    t.string   "account_number", :limit => 50, :null => false
    t.string   "bank_name",                    :null => false
    t.string   "rtgs_code",      :limit => 25
    t.string   "micr_code",      :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ifsc_code"
  end

  create_table "bank_statement_headers", :force => true do |t|
    t.integer  "bank_id"
    t.integer  "company_id"
    t.string   "header_1"
    t.string   "header_2"
    t.string   "header_3"
    t.string   "header_4"
    t.string   "header_5"
    t.string   "header_6"
    t.string   "header_7"
    t.string   "header_8"
    t.string   "date_format"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bank_statement_line_items", :force => true do |t|
    t.date     "date"
    t.string   "from_account"
    t.string   "to_account"
    t.decimal  "amount",                 :precision => 18, :scale => 2
    t.text     "description"
    t.integer  "status"
    t.integer  "bank_statement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.boolean  "credit_debit_indicator"
    t.integer  "company_id"
    t.decimal  "account_balance",        :precision => 18, :scale => 2
    t.integer  "ledger_id"
    t.date     "value_date"
    t.string   "cheque_reference"
  end

  create_table "bank_statements", :force => true do |t|
    t.integer  "company_id"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "status"
    t.integer  "account_id"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "billing_invoice_sequences", :force => true do |t|
  end

  create_table "billing_invoices", :force => true do |t|
    t.integer  "company_id"
    t.string   "invoice_number",                                                 :null => false
    t.datetime "invoice_date",                                                   :null => false
    t.decimal  "amount",         :precision => 18, :scale => 2, :default => 0.0
    t.integer  "created_by",                                                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id",                                     :default => 0,   :null => false
    t.string   "received_by"
    t.integer  "closed_by"
  end

  create_table "billing_line_items", :force => true do |t|
    t.integer "company_id",                                                         :null => false
    t.integer "billing_invoice_id",                                                 :null => false
    t.string  "line_item",                                                          :null => false
    t.decimal "amount",             :precision => 18, :scale => 2, :default => 0.0
    t.string  "billing_type",                                                       :null => false
    t.decimal "validity",           :precision => 10, :scale => 2
  end

  create_table "blog_categories", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blog_category_blog_posts", :force => true do |t|
    t.integer "blog_category_id", :null => false
    t.integer "blog_post_id",     :null => false
  end

  create_table "blog_posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.integer  "super_user_id"
    t.integer  "status"
    t.integer  "view_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "blog_category_id"
    t.text     "slug"
    t.string   "description"
    t.string   "author"
  end

  create_table "branches", :force => true do |t|
    t.integer  "company_id",                                  :null => false
    t.string   "name",                                        :null => false
    t.string   "phone",      :limit => 15
    t.string   "fax",        :limit => 15
    t.integer  "created_by",                                  :null => false
    t.boolean  "deleted",                  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gstin"
  end

  create_table "campaigns", :force => true do |t|
    t.string   "campaign_name"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "capital_accounts", :force => true do |t|
    t.string "name"
    t.text   "address"
    t.string "city"
    t.string "state"
    t.string "PIN"
    t.string "PAN"
    t.string "sales_tax_no"
    t.string "service_tax_no"
    t.string "email"
  end

  create_table "cash_accounts", :force => true do |t|
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cash_free_settings", :force => true do |t|
    t.integer  "company_id",          :null => false
    t.integer  "account_id",          :null => false
    t.string   "app_id",              :null => false
    t.string   "secret_key",          :null => false
    t.string   "status",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expense_account"
    t.integer  "expense_tax_account"
  end

  create_table "cashfree_documents", :force => true do |t|
    t.integer  "company_id"
    t.integer  "created_by"
    t.string   "uploaded_file_one_file_name"
    t.string   "uploaded_file_one_content_type"
    t.integer  "uploaded_file_one_file_size"
    t.datetime "uploaded_file_one_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_two_file_name"
    t.string   "uploaded_file_two_content_type"
    t.integer  "uploaded_file_two_file_size"
    t.datetime "uploaded_file_two_updated_at"
    t.string   "uploaded_file_three_file_name"
    t.string   "uploaded_file_three_content_type"
    t.integer  "uploaded_file_three_file_size"
    t.datetime "uploaded_file_three_updated_at"
    t.string   "name"
    t.string   "pan"
  end

  create_table "cashfree_payment_links", :force => true do |t|
    t.integer  "company_id",     :null => false
    t.integer  "invoice_id",     :null => false
    t.string   "order_id",       :null => false
    t.string   "order_amount",   :null => false
    t.string   "order_note"
    t.string   "customer_name"
    t.integer  "customer_phone", :null => false
    t.string   "customer_email"
    t.integer  "seller_phone"
    t.string   "shorturl"
    t.string   "created_by",     :null => false
    t.string   "status",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  create_table "cashfree_responses", :force => true do |t|
    t.string   "order_id",                                                                    :null => false
    t.decimal  "order_amount",                :precision => 18, :scale => 2, :default => 0.0
    t.string   "reference_id",                                                                :null => false
    t.string   "tx_status"
    t.string   "payment_mode"
    t.string   "tx_message",                                                                  :null => false
    t.string   "tx_time",                                                                     :null => false
    t.string   "signature",                                                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remote_ip",    :limit => 100
  end

  create_table "channels", :force => true do |t|
    t.string   "channel_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",       :default => false
  end

  create_table "client_invitations", :force => true do |t|
    t.string   "name",                                     :null => false
    t.integer  "sent_by",                                  :null => false
    t.string   "email",      :limit => 100,                :null => false
    t.string   "token",      :limit => 10,                 :null => false
    t.integer  "status_id",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "auditor_id"
  end

  create_table "companies", :force => true do |t|
    t.string   "name",                                                                                           :null => false
    t.string   "subdomain",                                                                                      :null => false
    t.string   "pan",                           :limit => 10
    t.string   "sales_tax_no",                  :limit => 100
    t.string   "tin",                           :limit => 100
    t.date     "activation_date",                                                                                :null => false
    t.date     "expiry_date"
    t.boolean  "reminder"
    t.integer  "active",                        :limit => 3
    t.boolean  "deleted",                                      :default => false
    t.datetime "deleted_datetime"
    t.string   "deleted_by"
    t.text     "deleted_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone",                         :limit => 100
    t.string   "fax",                           :limit => 100
    t.string   "email"
    t.string   "VAT_no"
    t.string   "CST_no"
    t.string   "excise_reg_no"
    t.string   "service_tax_reg_no"
    t.integer  "setup_progress"
    t.boolean  "subscription_type",                            :default => true
    t.integer  "status"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.integer  "payroll_date"
    t.text     "terms_and_conditions"
    t.text     "customer_note"
    t.string   "watermark",                     :limit => 150, :default => "Generated from www.profitbooks.net"
    t.integer  "country_id"
    t.string   "timezone"
    t.string   "tan_no"
    t.string   "lbt_registration_number"
    t.string   "facebook_url"
    t.string   "twitter_url"
    t.string   "linked_in_url"
    t.string   "google_plus_url"
    t.integer  "you_sell"
    t.integer  "business_type"
    t.integer  "industry"
    t.integer  "total_employees"
    t.integer  "source"
    t.integer  "current_system"
    t.integer  "annual_turnover"
    t.integer  "ca_status"
    t.text     "estimate_terms_and_conditions"
    t.string   "GSTIN",                         :limit => 15
    t.integer  "gst_category_id"
    t.string   "gstn_username"
  end

  add_index "companies", ["subdomain"], :name => "cmp_subdomain_idx"

  create_table "company_auditors", :force => true do |t|
    t.integer  "company_id",       :null => false
    t.integer  "auditor_id",       :null => false
    t.integer  "department_id"
    t.integer  "designation_id"
    t.integer  "reporting_to_id"
    t.datetime "last_login_at"
    t.boolean  "deleted"
    t.datetime "deleted_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_currencies", :force => true do |t|
    t.integer  "company_id"
    t.integer  "currency_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_notes", :force => true do |t|
    t.integer  "company_id"
    t.text     "description"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_templates", :force => true do |t|
    t.integer  "company_id",   :null => false
    t.integer  "template_id",  :null => false
    t.string   "voucher_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "company_id",                      :null => false
    t.integer  "created_by",                      :null => false
    t.string   "title"
    t.string   "first_name",       :limit => 100
    t.string   "last_name",        :limit => 100
    t.string   "email",            :limit => 100
    t.string   "gender"
    t.date     "birthday"
    t.date     "anniversary"
    t.text     "address1"
    t.text     "address2"
    t.string   "city"
    t.string   "state"
    t.string   "pin_code"
    t.string   "country"
    t.string   "phone1",           :limit => 10
    t.string   "phone2",           :limit => 10
    t.string   "mobile",           :limit => 10
    t.string   "business_fax",     :limit => 15
    t.string   "contact_category"
    t.string   "designation"
    t.string   "department"
    t.string   "company"
    t.string   "account"
    t.text     "notes"
    t.string   "web_page"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "sundry_debtor_id"
    t.string   "role",             :limit => 50
    t.string   "position",         :limit => 50
    t.string   "previous_company", :limit => 50
  end

  create_table "countries", :force => true do |t|
    t.string   "name",             :limit => 80
    t.string   "isd_code",         :limit => 5
    t.string   "currency_unicode", :limit => 10
    t.string   "currency_code",    :limit => 3
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "country_companies", :force => true do |t|
    t.integer  "company_id"
    t.integer  "country_id"
    t.string   "timezone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_transactions", :force => true do |t|
    t.integer  "coupon_id"
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupons", :force => true do |t|
    t.string   "name"
    t.string   "coupon_code"
    t.string   "coupon_type"
    t.decimal  "discount",          :precision => 10, :scale => 0
    t.decimal  "total_amount",      :precision => 10, :scale => 0
    t.date     "date_start"
    t.date     "date_end"
    t.integer  "uses_per_coupon"
    t.integer  "uses_per_customer"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "year",              :precision => 10, :scale => 0
  end

  create_table "credit_note_sequences", :force => true do |t|
    t.integer  "company_id",                          :null => false
    t.integer  "credit_note_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "credit_notes", :force => true do |t|
    t.integer  "company_id",                                                           :null => false
    t.integer  "created_by",                                                           :null => false
    t.string   "credit_note_number",                                                   :null => false
    t.date     "transaction_date",                                                     :null => false
    t.decimal  "amount",             :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.integer  "from_account_id"
    t.integer  "to_account_id",                                                        :null => false
    t.text     "description"
    t.boolean  "deleted",                                           :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.boolean  "opened",                                            :default => true
    t.integer  "invoice_return_id"
    t.boolean  "read_only",                                         :default => false
  end

  create_table "currencies", :force => true do |t|
    t.string   "currency_code", :limit => 3,  :null => false
    t.string   "symbol",        :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["currency_code"], :name => "curcode_idx"

  create_table "current_assets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "current_liabilities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_fields", :force => true do |t|
    t.integer  "company_id",                        :null => false
    t.string   "voucher_type",                      :null => false
    t.string   "custom_label1"
    t.string   "custom_label2"
    t.string   "custom_label3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",         :default => false
    t.string   "default_value1"
    t.string   "default_value2"
    t.string   "default_value3"
  end

  create_table "customer_imports", :force => true do |t|
    t.integer  "import_file_id"
    t.string   "name"
    t.string   "opening_balance"
    t.string   "currency"
    t.string   "primary_phone_number",    :limit => 30
    t.string   "email"
    t.string   "website"
    t.string   "pan"
    t.string   "tan"
    t.string   "vat_tin"
    t.string   "cst_reg_no"
    t.string   "cin"
    t.string   "excise_reg_no"
    t.string   "service_tax_reg_no"
    t.string   "lbt_registration_number"
    t.string   "credit_days"
    t.string   "credit_limit"
    t.string   "billing_address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal_code"
    t.string   "shipping_address"
    t.integer  "created_by"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tax_number",              :limit => 32
    t.string   "start_date",              :limit => 15
    t.string   "shipping_city"
    t.string   "shipping_state",          :limit => 100
    t.string   "shipping_country"
    t.string   "shipping_postal_code",    :limit => 15
    t.string   "secondary_phone_number",  :limit => 25
    t.integer  "company_id",                             :null => false
  end

  create_table "customer_relationships", :force => true do |t|
    t.integer  "company_id"
    t.text     "notes"
    t.date     "last_contact_date"
    t.date     "next_contact_date"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "notable_id"
    t.string   "notable_type"
    t.integer  "activity"
    t.date     "record_date"
    t.decimal  "time_spent",        :precision => 10, :scale => 0
    t.boolean  "activity_status",                                  :default => false
    t.string   "next_folloup_time"
    t.integer  "next_activity"
    t.date     "completed_date"
  end

  create_table "customers", :force => true do |t|
    t.integer  "company_id",                                                                            :null => false
    t.string   "name",                                                                                  :null => false
    t.string   "primary_phone_number"
    t.string   "fax"
    t.string   "email"
    t.string   "website"
    t.string   "pan",                      :limit => 25
    t.string   "tan",                      :limit => 25
    t.string   "vat_tin",                  :limit => 25
    t.string   "cst_reg_no",               :limit => 25
    t.string   "cin",                      :limit => 25
    t.string   "excise_reg_no",            :limit => 25
    t.string   "service_tax_reg_no",       :limit => 25
    t.integer  "product_pricing_level_id"
    t.string   "country",                  :limit => 100
    t.string   "weekly_off",               :limit => 50
    t.string   "open_time",                :limit => 10
    t.string   "close_time",               :limit => 10
    t.string   "bank_name"
    t.string   "ifsc_code",                :limit => 25
    t.string   "micr_code",                :limit => 25
    t.string   "bsr_code",                 :limit => 25
    t.date     "incorporated_date"
    t.integer  "credit_days",                                                            :default => 0
    t.decimal  "credit_limit",                            :precision => 10, :scale => 0, :default => 0
    t.integer  "created_by",                                                                            :null => false
    t.text     "background_info"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sales_tax_no"
    t.string   "lbt_registration_number"
    t.integer  "currency_id"
    t.string   "secondary_phone_number"
    t.string   "gstn_id"
    t.string   "tax_reg_no"
    t.integer  "gst_category_id",          :limit => 3
  end

  add_index "customers", ["company_id"], :name => "cust_comp_idx"

  create_table "debit_note_sequences", :force => true do |t|
    t.integer  "company_id",                         :null => false
    t.integer  "debit_note_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "debit_notes", :force => true do |t|
    t.integer  "company_id",                                                           :null => false
    t.integer  "created_by",                                                           :null => false
    t.string   "debit_note_number",                                                    :null => false
    t.date     "transaction_date",                                                     :null => false
    t.decimal  "amount",             :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.integer  "from_account_id"
    t.integer  "to_account_id",                                                        :null => false
    t.text     "description"
    t.boolean  "deleted",                                           :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.boolean  "opened",                                            :default => true
    t.integer  "purchase_return_id"
    t.boolean  "read_only",                                         :default => false
  end

  create_table "deferred_tax_asset_or_liabilities", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "delivery_challan_line_items", :force => true do |t|
    t.integer  "delivery_challan_id",                                     :null => false
    t.integer  "product_id",                                              :null => false
    t.decimal  "quantity",                 :precision => 10, :scale => 2
    t.text     "description"
    t.integer  "product_batch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sales_order_line_item_id"
  end

  create_table "delivery_challan_sequences", :force => true do |t|
    t.integer  "company_id"
    t.integer  "delivery_challan_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delivery_challans", :force => true do |t|
    t.integer  "company_id",                          :null => false
    t.integer  "created_by",                          :null => false
    t.integer  "sales_order_id",                      :null => false
    t.integer  "account_id"
    t.integer  "warehouse_id"
    t.string   "voucher_number",                      :null => false
    t.date     "voucher_date",                        :null => false
    t.integer  "status",               :default => 0
    t.text     "customer_notes"
    t.text     "terms_and_conditions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  create_table "departments", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deposit_accounts", :force => true do |t|
    t.boolean "interest_applicable"
    t.decimal "interest_rate",       :precision => 4, :scale => 2
    t.integer "compounding_type"
  end

  create_table "deposit_sequences", :force => true do |t|
    t.integer  "company_id",                      :null => false
    t.integer  "deposit_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deposits", :force => true do |t|
    t.integer  "company_id",                                                          :null => false
    t.integer  "created_by",                                                          :null => false
    t.string   "voucher_number"
    t.date     "transaction_date"
    t.integer  "from_account_id",                                                     :null => false
    t.integer  "to_account_id",                                                       :null => false
    t.decimal  "amount",            :precision => 18, :scale => 2, :default => 0.0
    t.string   "description"
    t.boolean  "deleted",                                          :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "designations", :force => true do |t|
    t.integer  "company_id",  :null => false
    t.string   "title",       :null => false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "direct_expense_accounts", :force => true do |t|
    t.boolean "inventoriable"
  end

  create_table "direct_income_accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "duties_and_taxes_accounts", :force => true do |t|
    t.integer  "tax_id"
    t.decimal  "tax_rate",             :precision => 4, :scale => 2
    t.boolean  "auto_calculate_tax"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "filling_frequency"
    t.string   "registration_number"
    t.integer  "apply_to"
    t.text     "description"
    t.decimal  "calculate_on_percent", :precision => 5, :scale => 2, :default => 100.0
    t.integer  "calculation_method",                                 :default => 0
    t.integer  "split_tax"
  end

  create_table "email_templates", :force => true do |t|
    t.string   "template_name"
    t.string   "subject"
    t.string   "header"
    t.string   "body"
    t.string   "footer"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "email"
  end

  create_table "employee_goals", :force => true do |t|
    t.integer  "company_id",        :null => false
    t.integer  "for_employee",      :null => false
    t.integer  "created_by",        :null => false
    t.integer  "goals"
    t.date     "from_date",         :null => false
    t.date     "to_date",           :null => false
    t.text     "employee_comments"
    t.text     "manager_comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimate_histories", :force => true do |t|
    t.integer  "estimate_id"
    t.integer  "company_id"
    t.string   "description"
    t.integer  "created_by"
    t.datetime "record_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimate_line_items", :force => true do |t|
    t.integer  "estimate_id",                                                    :null => false
    t.integer  "account_id"
    t.decimal  "quantity",       :precision => 10, :scale => 2
    t.decimal  "unit_rate",      :precision => 18, :scale => 4
    t.decimal  "discount",       :precision => 4,  :scale => 2
    t.boolean  "tax"
    t.decimal  "amount",         :precision => 18, :scale => 2, :default => 0.0
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "line_item_type"
    t.integer  "product_id"
    t.integer  "tax_account_id"
  end

  create_table "estimate_sequences", :force => true do |t|
    t.integer  "company_id",                       :null => false
    t.integer  "estimate_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimate_taxes", :force => true do |t|
    t.integer  "estimate_line_item_id", :null => false
    t.integer  "account_id",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "estimates", :force => true do |t|
    t.integer  "company_id",                                                                             :null => false
    t.integer  "account_id",                                                                             :null => false
    t.integer  "created_by",                                                                             :null => false
    t.string   "estimate_number"
    t.date     "estimate_date",                                                                          :null => false
    t.text     "customer_notes"
    t.text     "terms_and_conditions"
    t.integer  "status"
    t.boolean  "deleted",                                                             :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "due_date"
    t.integer  "branch_id"
    t.string   "custom_field1"
    t.string   "custom_field2"
    t.string   "custom_field3"
    t.decimal  "total_amount",                         :precision => 18, :scale => 2, :default => 0.0
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                        :precision => 18, :scale => 5, :default => 0.0
    t.boolean  "tax_inclusive",                                                       :default => false
    t.boolean  "gst_estimate",                                                        :default => false
    t.string   "place_of_supply",         :limit => 3
    t.boolean  "export_estimate",                                                     :default => false
  end

  create_table "expense_line_items", :force => true do |t|
    t.integer  "expense_id",                                                  :null => false
    t.integer  "account_id",                                                  :null => false
    t.decimal  "amount",      :precision => 18, :scale => 2, :default => 0.0
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "tax"
    t.string   "type"
    t.string   "eligibility"
    t.decimal  "igst",        :precision => 10, :scale => 0
    t.decimal  "cgst",        :precision => 10, :scale => 0
    t.decimal  "sgst",        :precision => 10, :scale => 0
  end

  create_table "expense_sequences", :force => true do |t|
    t.integer  "company_id",                      :null => false
    t.integer  "expense_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expense_taxes", :force => true do |t|
    t.integer  "expense_line_item_id", :null => false
    t.integer  "account_id",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expenses", :force => true do |t|
    t.integer  "company_id",                                                                                 :null => false
    t.integer  "account_id",                                                                                 :null => false
    t.integer  "created_by",                                                                                 :null => false
    t.string   "voucher_number",             :limit => 25
    t.date     "expense_date"
    t.text     "customer_notes"
    t.text     "tags"
    t.boolean  "deleted",                                                                 :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.integer  "project_id"
    t.integer  "branch_id"
    t.decimal  "total_amount",                             :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "credit_expense",                                                          :default => false
    t.date     "due_date"
    t.integer  "status_id",                                                               :default => 1
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                            :precision => 18, :scale => 5, :default => 0.0
    t.boolean  "gst_expense",                                                             :default => false
    t.boolean  "reverse_charge",                                                          :default => false
  end

  create_table "expenses_payments", :force => true do |t|
    t.integer  "payment_voucher_id"
    t.integer  "expense_id"
    t.decimal  "amount",             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "tds_amount",         :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "deleted",                                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "export_port_codes", :force => true do |t|
    t.string   "port_code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "company_id",   :null => false
    t.integer  "submitted_by"
    t.string   "vote"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "financial_year_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "financial_year_id"
    t.datetime "activity_on"
    t.integer  "activity"
    t.decimal  "past_opening_balance", :precision => 10, :scale => 0, :default => 0
    t.decimal  "past_closing_balance", :precision => 10, :scale => 0, :default => 0
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "financial_years", :force => true do |t|
    t.integer "company_id",                                                                :null => false
    t.integer "year_id",                                                                   :null => false
    t.boolean "freeze",                                                 :default => false
    t.date    "start_date",                                                                :null => false
    t.date    "end_date",                                                                  :null => false
    t.decimal "opening_balance",         :precision => 18, :scale => 2, :default => 0.0
    t.decimal "closing_balance",         :precision => 18, :scale => 2
    t.decimal "opening_stock_valuation", :precision => 18, :scale => 2, :default => 0.0
    t.decimal "closing_stock_valuation", :precision => 18, :scale => 2, :default => 0.0
  end

  add_index "financial_years", ["year_id", "company_id"], :name => "finyr_yrid_compid_idx"

  create_table "finished_goods", :force => true do |t|
    t.integer  "company_id",    :null => false
    t.integer  "user_id"
    t.integer  "inventory_id",  :null => false
    t.integer  "recieved_from"
    t.integer  "quantity"
    t.date     "recieved_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fixed_assets", :force => true do |t|
    t.boolean  "depreciable"
    t.decimal  "depreciation_rate", :precision => 8, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "folders", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "parent_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "folders", ["parent_id"], :name => "index_folders_on_parent_id"
  add_index "folders", ["user_id"], :name => "index_folders_on_user_id"

  create_table "grants", :force => true do |t|
    t.integer  "right_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "grants", ["role_id", "right_id"], :name => "grnts_roleid_rightid_idx"

  create_table "gsps", :force => true do |t|
    t.string   "name",                      :null => false
    t.string   "url",                       :null => false
    t.string   "env",        :limit => 150, :null => false
    t.string   "version",    :limit => 25,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_actions", :force => true do |t|
    t.string   "action"
    t.string   "url"
    t.string   "version"
    t.string   "gst_retrun_type"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_categories", :force => true do |t|
    t.string "name",        :null => false
    t.text   "description"
  end

  create_table "gst_credit_allocations", :force => true do |t|
    t.integer  "invoice_id",                                                           :null => false
    t.integer  "gst_credit_note_id",                                                   :null => false
    t.decimal  "amount",             :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.boolean  "deleted",                                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_credit_note_line_items", :force => true do |t|
    t.integer  "gst_credit_note_id"
    t.integer  "account_id"
    t.integer  "from_account_id"
    t.decimal  "quantity",           :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "unit_rate",          :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "tax",                                               :default => false
    t.decimal  "amount",             :precision => 18, :scale => 2, :default => 0.0
    t.string   "line_type"
    t.integer  "product_id"
    t.integer  "tax_account_id"
    t.decimal  "discount_percent",   :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_credit_note_sequences", :force => true do |t|
    t.integer  "company_id",                              :null => false
    t.integer  "gst_credit_note_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_credit_note_taxes", :force => true do |t|
    t.integer  "gst_credit_note_line_item_id", :null => false
    t.integer  "account_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_credit_notes", :force => true do |t|
    t.integer  "company_id",                                                             :null => false
    t.integer  "to_account_id",                                                          :null => false
    t.string   "gst_credit_note_number",                                                 :null => false
    t.date     "gst_credit_note_date",                                                   :null => false
    t.decimal  "amount",                 :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.integer  "created_by",                                                             :null => false
    t.integer  "status_id",                                             :default => 0,   :null => false
    t.integer  "invoice_return_id",                                                      :null => false
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_debit_allocations", :force => true do |t|
    t.integer  "purchase_id"
    t.integer  "gst_debit_note_id"
    t.decimal  "amount",            :precision => 18, :scale => 2
    t.boolean  "deleted",                                          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_debit_note_line_items", :force => true do |t|
    t.integer  "gst_debit_note_id",                                                   :null => false
    t.integer  "account_id"
    t.decimal  "quantity",          :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "unit_rate",         :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "tax",                                              :default => false
    t.decimal  "amount",            :precision => 18, :scale => 2, :default => 0.0
    t.string   "line_type"
    t.integer  "product_id"
    t.integer  "tax_account_id"
    t.decimal  "discount_percent",  :precision => 10, :scale => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_debit_note_sequences", :force => true do |t|
    t.integer  "company_id",                             :null => false
    t.integer  "gst_debit_note_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_debit_note_taxes", :force => true do |t|
    t.integer  "gst_debit_note_line_item_id", :null => false
    t.integer  "account_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_debit_notes", :force => true do |t|
    t.integer  "company_id",                                                            :null => false
    t.string   "gst_debit_note_number"
    t.datetime "gst_debit_note_date"
    t.decimal  "amount",                :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.integer  "from_account_id",                                                       :null => false
    t.integer  "to_account_id",                                                         :null => false
    t.integer  "created_by",                                                            :null => false
    t.integer  "purchase_return_id",                                                    :null => false
    t.integer  "status_id",                                                             :null => false
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_request_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "gsp_id"
    t.string   "action"
    t.string   "txn"
    t.text     "payload"
    t.string   "usr_ip_addr"
    t.datetime "sent_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_response_logs", :force => true do |t|
    t.integer  "company_id"
    t.integer  "gsp_id"
    t.string   "action"
    t.string   "txn"
    t.text     "payload"
    t.string   "usr_ip_addr"
    t.datetime "received_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gst_return_types", :force => true do |t|
    t.integer "gst_category_id",                 :null => false
    t.string  "return_type",                     :null => false
    t.string  "filing_frequency", :limit => 100, :null => false
    t.text    "description"
  end

  create_table "gst_returns", :force => true do |t|
    t.integer  "company_id"
    t.integer  "financial_year_id"
    t.integer  "month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr1_counter_party_summaries", :force => true do |t|
    t.integer  "gstr1_section_summary_id",                                                               :null => false
    t.string   "ctin",                     :limit => 15
    t.string   "chksum",                   :limit => 64
    t.integer  "total_record",                                                          :default => 0
    t.decimal  "total_value",                            :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_igst",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_cgst",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_sgst",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_cess",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_taxable_value",                    :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr1_section_summaries", :force => true do |t|
    t.integer  "gstr1_summary_id",                                                                  :null => false
    t.string   "section_type",        :limit => 20,                                                 :null => false
    t.string   "chksum",              :limit => 64
    t.integer  "total_record",                                                     :default => 0
    t.decimal  "total_value",                       :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_igst",                        :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_cgst",                        :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_sgst",                        :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_cess",                        :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_taxable_value",               :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "nil_supply_amt",                    :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "exempted_supply_amt",               :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "ngsup_outward_amt",                 :precision => 18, :scale => 2, :default => 0.0
    t.integer  "total_doc_issued",                                                 :default => 0
    t.integer  "total_doc_cancelled",                                              :default => 0
    t.integer  "net_doc_issued",                                                   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr1_state_code_summaries", :force => true do |t|
    t.integer  "gstr1_section_summary_id",                                                               :null => false
    t.string   "state_code",               :limit => 2
    t.string   "chksum",                   :limit => 64
    t.integer  "total_record",                                                          :default => 0
    t.decimal  "total_value",                            :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_igst",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_cgst",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_sgst",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_cess",                             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "total_taxable_value",                    :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr1_summaries", :force => true do |t|
    t.integer  "company_id",                  :null => false
    t.integer  "gstr_one_id",                 :null => false
    t.string   "summary_type",  :limit => 2
    t.string   "return_period", :limit => 6
    t.string   "chksum",        :limit => 64
    t.integer  "status",        :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr2_summaries", :force => true do |t|
    t.integer  "company_id",                  :null => false
    t.integer  "gstr_two_id",                 :null => false
    t.string   "summary_type",  :limit => 2
    t.string   "return_period", :limit => 6
    t.string   "chksum",        :limit => 64
    t.integer  "status",        :limit => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr2a_items", :force => true do |t|
    t.integer  "company_id",                                                                      :null => false
    t.integer  "gstr2a_id",                                                                       :null => false
    t.integer  "category"
    t.integer  "ctin"
    t.string   "chksum",          :limit => 64
    t.string   "voucher_num",     :limit => 16
    t.string   "voucher_type"
    t.date     "voucher_date"
    t.decimal  "voucher_value",                 :precision => 15, :scale => 2
    t.string   "place_of_supply", :limit => 2
    t.boolean  "reverse_charge",                                               :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr2a_line_items", :force => true do |t|
    t.integer  "company_id",                                    :null => false
    t.integer  "gstr2a_item_id",                                :null => false
    t.integer  "item_id"
    t.decimal  "taxable_value",  :precision => 11, :scale => 2
    t.decimal  "igst_amt",       :precision => 11, :scale => 2
    t.decimal  "cgst_amt",       :precision => 11, :scale => 2
    t.decimal  "sgst_amt",       :precision => 11, :scale => 2
    t.decimal  "cess_amt",       :precision => 11, :scale => 2
    t.decimal  "tax_rate",       :precision => 3,  :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr2as", :force => true do |t|
    t.integer  "company_id",                       :null => false
    t.integer  "month"
    t.integer  "year"
    t.integer  "status",            :default => 0
    t.integer  "financial_year_id",                :null => false
    t.integer  "gst_return_id",                    :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr3b_reports", :force => true do |t|
    t.integer  "company_id",                      :null => false
    t.integer  "financial_year_id",               :null => false
    t.integer  "month",                           :null => false
    t.string   "gstin",             :limit => 15, :null => false
    t.integer  "status",                          :null => false
    t.string   "name",                            :null => false
    t.integer  "verified_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_payment_histories", :force => true do |t|
    t.integer  "gstr_advance_payment_id"
    t.integer  "company_id"
    t.text     "description"
    t.integer  "created_by"
    t.datetime "payment_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_payment_line_items", :force => true do |t|
    t.integer  "gstr_advance_payment_id"
    t.integer  "purchase_id"
    t.integer  "product_id"
    t.decimal  "quantity",                :precision => 10, :scale => 2
    t.decimal  "unit_rate",               :precision => 18, :scale => 2
    t.decimal  "discount_percentage",     :precision => 4,  :scale => 2
    t.decimal  "amount",                  :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.text     "description"
    t.integer  "account_id"
    t.decimal  "tax_amount",              :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.string   "line_item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_payment_taxes", :force => true do |t|
    t.integer  "gstr_advance_payment_line_item_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_payment_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                                           :null => false
    t.integer  "gstr_advance_payment_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_payments", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.string   "voucher_number",    :limit => 32
    t.date     "voucher_date"
    t.date     "received_date"
    t.integer  "from_account_id"
    t.integer  "to_account_id"
    t.decimal  "amount",                          :precision => 18, :scale => 2, :default => 0.0
    t.text     "payment_details"
    t.boolean  "deleted",                                                        :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.integer  "project_id"
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                   :precision => 18, :scale => 5, :default => 0.0
    t.integer  "status"
    t.integer  "created_by",                                                                        :null => false
    t.integer  "purchase_id"
    t.string   "place_of_supply",   :limit => 3,                                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_purchases_payments", :force => true do |t|
    t.integer  "gstr_advance_payment_id"
    t.integer  "purchase_id"
    t.decimal  "amount",                  :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "deleted",                                                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_receipt_histories", :force => true do |t|
    t.integer  "gstr_advance_receipt_id"
    t.integer  "company_id"
    t.text     "description"
    t.integer  "to_account_id"
    t.datetime "received_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_receipt_invoices", :force => true do |t|
    t.integer  "gstr_advance_receipt_id"
    t.integer  "invoice_id"
    t.decimal  "amount",                  :precision => 18, :scale => 4
    t.boolean  "deleted",                                                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_receipt_line_items", :force => true do |t|
    t.integer  "gstr_advance_receipt_id",                                                 :null => false
    t.integer  "account_id"
    t.decimal  "quantity",                :precision => 18, :scale => 4
    t.decimal  "unit_rate",               :precision => 18, :scale => 4
    t.decimal  "discount_percentage",     :precision => 18, :scale => 4
    t.decimal  "amount",                  :precision => 18, :scale => 4
    t.integer  "product_id"
    t.text     "description"
    t.decimal  "tax_amount",              :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.string   "line_item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_receipt_taxes", :force => true do |t|
    t.integer  "gstr_advance_receipt_line_item_id"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_receipt_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                                           :null => false
    t.integer  "gstr_advance_receipt_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_advance_receipts", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.string   "voucher_number",    :limit => 32
    t.date     "voucher_date"
    t.date     "received_date"
    t.integer  "from_account_id",                                                                   :null => false
    t.integer  "to_account_id",                                                                     :null => false
    t.decimal  "amount",                          :precision => 18, :scale => 4, :default => 0.0
    t.text     "payment_details"
    t.boolean  "deleted",                                                        :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.integer  "currency_id"
    t.integer  "project_id"
    t.decimal  "exchange_rate",                   :precision => 18, :scale => 5, :default => 0.0
    t.integer  "status"
    t.integer  "created_by",                                                                        :null => false
    t.string   "place_of_supply",   :limit => 3,                                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_one_items", :force => true do |t|
    t.integer  "company_id",             :null => false
    t.integer  "gstr_one_id",            :null => false
    t.integer  "voucher_id",             :null => false
    t.string   "voucher_type"
    t.integer  "voucher_classification"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "error_msg"
  end

  create_table "gstr_ones", :force => true do |t|
    t.integer  "company_id",                                                                      :null => false
    t.integer  "financial_year_id",                                                               :null => false
    t.integer  "month"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gst_return_id",                                                                   :null => false
    t.date     "due_date",                                                                        :null => false
    t.string   "gst_reference"
    t.string   "year",               :limit => 4
    t.decimal  "fy_gross_turnover",               :precision => 18, :scale => 2, :default => 2.0
    t.decimal  "qtr_gross_turnover",              :precision => 18, :scale => 2, :default => 2.0
  end

  create_table "gstr_two_items", :force => true do |t|
    t.integer  "company_id",             :null => false
    t.integer  "gstr_two_id",            :null => false
    t.integer  "voucher_id",             :null => false
    t.string   "voucher_type"
    t.string   "voucher_number"
    t.integer  "voucher_classification"
    t.integer  "status"
    t.string   "error_msg"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gstr_twos", :force => true do |t|
    t.integer  "company_id",                     :null => false
    t.integer  "financial_year_id",              :null => false
    t.integer  "month"
    t.integer  "status"
    t.string   "year",              :limit => 4
    t.string   "error_msg"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gst_return_id",                  :null => false
    t.date     "due_date"
    t.string   "gst_reference"
  end

  create_table "helps", :force => true do |t|
    t.string   "screen_name"
    t.integer  "screen_id"
    t.string   "help"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "holidays", :force => true do |t|
    t.date     "holiday_date", :null => false
    t.string   "holiday",      :null => false
    t.text     "description"
    t.integer  "created_by",   :null => false
    t.integer  "company_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hsn_chapters", :force => true do |t|
    t.integer  "chapter_index"
    t.string   "chapter_heading"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hsn_codes", :force => true do |t|
    t.string   "product_code"
    t.string   "HSN_Code"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code_type"
  end

  create_table "import_files", :force => true do |t|
    t.integer  "company_id",        :null => false
    t.integer  "item_type",         :null => false
    t.integer  "created_by",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.integer  "status"
  end

  create_table "income_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                             :null => false
    t.integer  "income_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "income_vouchers", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.integer  "created_by",                                                                        :null => false
    t.string   "voucher_number",    :limit => 32,                                                   :null => false
    t.date     "income_date",                                                                       :null => false
    t.integer  "from_account_id",                                                                   :null => false
    t.integer  "to_account_id",                                                                     :null => false
    t.decimal  "amount",                          :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.text     "description"
    t.boolean  "deleted",                                                        :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "indirect_expense_accounts", :force => true do |t|
    t.boolean "inventoriable"
  end

  create_table "indirect_income_accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instamojo_payment_links", :force => true do |t|
    t.integer  "company_id",         :null => false
    t.integer  "invoice_id",         :null => false
    t.string   "payment_request_id", :null => false
    t.string   "customer_name"
    t.string   "purpose",            :null => false
    t.string   "amount",             :null => false
    t.string   "longurl",            :null => false
    t.string   "shorturl"
    t.string   "created_by",         :null => false
    t.string   "status",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id",        :null => false
  end

  create_table "instamojo_payments", :force => true do |t|
    t.integer  "company_id",   :null => false
    t.string   "account_name", :null => false
    t.string   "api_key",      :null => false
    t.string   "auth_key",     :null => false
    t.string   "status",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "salt_key",     :null => false
    t.integer  "account_id",   :null => false
  end

  create_table "inventories", :force => true do |t|
    t.integer  "company_id",      :null => false
    t.integer  "user_id",         :null => false
    t.integer  "account_id",      :null => false
    t.integer  "cutoff_level1"
    t.integer  "cutoff_level2"
    t.integer  "quantity"
    t.string   "unit_of_measure"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_settings", :force => true do |t|
    t.integer  "company_id",                                                  :null => false
    t.boolean  "purchase_effects_inventory",               :default => false, :null => false
    t.string   "inventory_model",            :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investment_accounts", :force => true do |t|
    t.boolean "inventoriable"
  end

  create_table "invitation_details", :force => true do |t|
    t.integer  "company_id",                               :null => false
    t.integer  "sent_by",                                  :null => false
    t.string   "email",      :limit => 100,                :null => false
    t.string   "token",                                    :null => false
    t.integer  "status_id",                 :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "invoice_attachments", :force => true do |t|
    t.integer  "company_id",                 :null => false
    t.integer  "created_by",                 :null => false
    t.string   "invoice_id",                 :null => false
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_credit_allocations", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "credit_note_id"
    t.decimal  "amount",         :precision => 18, :scale => 2
    t.boolean  "deleted",                                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_histories", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "company_id"
    t.string   "description"
    t.integer  "created_by"
    t.datetime "record_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_histories", ["invoice_id", "record_date"], :name => "inv_hist_fk_recrd_dt_idx"

  create_table "invoice_line_items", :force => true do |t|
    t.integer  "invoice_id",                                                       :null => false
    t.integer  "account_id"
    t.decimal  "quantity",         :precision => 10, :scale => 2
    t.decimal  "unit_rate",        :precision => 18, :scale => 4
    t.decimal  "discount_percent", :precision => 5,  :scale => 2, :default => 0.0
    t.string   "cost_center"
    t.boolean  "tax"
    t.decimal  "amount",           :precision => 18, :scale => 2, :default => 0.0
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "warehouse_id"
    t.integer  "product_id"
    t.integer  "tax_account_id"
    t.integer  "task_id"
  end

  add_index "invoice_line_items", ["invoice_id"], :name => "inv_ln_item_fk_idx"
  add_index "invoice_line_items", ["product_id"], :name => "inv_ln_item_product_idx"

  create_table "invoice_return_line_items", :force => true do |t|
    t.integer  "invoice_return_id"
    t.integer  "account_id"
    t.decimal  "quantity",             :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "unit_rate",            :precision => 18, :scale => 4, :default => 0.0
    t.boolean  "tax",                                                 :default => false
    t.decimal  "amount",               :precision => 18, :scale => 2, :default => 0.0
    t.string   "line_type"
    t.integer  "product_id"
    t.integer  "tax_account_id"
    t.decimal  "discount_percent",     :precision => 8,  :scale => 2
    t.integer  "invoice_line_item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invoice_return_line_items", ["product_id"], :name => "inv_rtrn_ln_item_product_idx"

  create_table "invoice_return_sequences", :force => true do |t|
    t.integer  "company_id"
    t.integer  "invoice_return_sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_return_taxes", :force => true do |t|
    t.integer  "invoice_return_line_item_id", :null => false
    t.integer  "account_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_returns", :force => true do |t|
    t.integer  "company_id",                                                            :null => false
    t.integer  "invoice_id",                                                            :null => false
    t.integer  "created_by",                                                            :null => false
    t.string   "invoice_return_number"
    t.integer  "account_id",                                                            :null => false
    t.date     "record_date"
    t.text     "description"
    t.decimal  "total_amount",          :precision => 18, :scale => 2, :default => 0.0
    t.integer  "currency_id"
    t.decimal  "exchange_rate",         :precision => 18, :scale => 5, :default => 0.0
    t.integer  "credit_note_id"
    t.integer  "warehouse_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "invoice_sales_orders", :force => true do |t|
    t.integer  "invoice_id",     :null => false
    t.integer  "sales_order_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_settings", :force => true do |t|
    t.integer  "company_id",                             :null => false
    t.integer  "invoice_sequence",    :default => 0
    t.integer  "invoice_no_strategy", :default => 0,     :null => false
    t.string   "invoice_prefix"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "invoice_suffix"
    t.string   "item_label"
    t.string   "desc_label"
    t.string   "qty_label"
    t.string   "rate_label"
    t.string   "discount_label"
    t.string   "amount_label"
    t.text     "invoice_footer"
    t.boolean  "view_payment",        :default => true
    t.boolean  "enable_gateway",      :default => false
    t.boolean  "enable_cashfree",     :default => false
  end

  create_table "invoice_statuses", :force => true do |t|
    t.string   "status",      :null => false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoice_taxes", :force => true do |t|
    t.integer  "invoice_line_item_id", :null => false
    t.integer  "account_id",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invoices", :force => true do |t|
    t.integer  "company_id",                                                                               :null => false
    t.integer  "account_id"
    t.integer  "created_by",                                                                               :null => false
    t.string   "invoice_number"
    t.date     "invoice_date",                                                                             :null => false
    t.date     "due_date",                                                                                 :null => false
    t.string   "po_reference"
    t.text     "customer_notes"
    t.text     "terms_and_conditions"
    t.integer  "invoice_status_id"
    t.boolean  "deleted",                                                               :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cash_invoice",                                                          :default => false
    t.string   "cash_customer_name"
    t.string   "cash_customer_mobile"
    t.string   "cash_customer_email"
    t.integer  "project_id"
    t.string   "custom_field1"
    t.string   "custom_field2"
    t.string   "custom_field3"
    t.integer  "branch_id"
    t.boolean  "time_invoice",                                                          :default => false
    t.integer  "recursive_invoice",                                                     :default => 0
    t.decimal  "total_amount",                           :precision => 18, :scale => 2, :default => 0.0
    t.integer  "voucher_title_id"
    t.integer  "so_invoice",                                                            :default => 0
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                          :precision => 18, :scale => 5, :default => 1.0
    t.boolean  "tax_inclusive",                                                         :default => false
    t.integer  "settlement_account_id"
    t.decimal  "settlement_exchange_rate",               :precision => 18, :scale => 5, :default => 0.0
    t.integer  "financial_year_id"
    t.integer  "estimate_id"
    t.integer  "customer_id"
    t.integer  "vendor_id"
    t.string   "place_of_supply",          :limit => 3
    t.boolean  "gst_invoice",                                                           :default => false
    t.string   "cash_customer_gstin",      :limit => 15
    t.boolean  "export_invoice",                                                        :default => false
    t.string   "sbpcode",                  :limit => 6
    t.string   "sbnum",                    :limit => 7
    t.date     "sbdate"
  end

  add_index "invoices", ["company_id", "invoice_status_id", "due_date"], :name => "inv_cmp_stats_due_date"

  create_table "invoices_receipts", :force => true do |t|
    t.integer  "receipt_voucher_id"
    t.integer  "invoice_id"
    t.decimal  "amount",             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "tds_amount",         :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",                                           :default => false
  end

  add_index "invoices_receipts", ["invoice_id"], :name => "invoice_idx"

  create_table "issue_raw_materials", :force => true do |t|
    t.integer  "company_id",   :null => false
    t.integer  "inventory_id", :null => false
    t.integer  "issued_to",    :null => false
    t.date     "issue_date"
    t.integer  "quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "company_id",   :null => false
    t.string   "title",        :null => false
    t.text     "description"
    t.string   "status"
    t.date     "joining_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_import_line_items", :force => true do |t|
    t.integer  "journal_import_id"
    t.integer  "from_account_id"
    t.decimal  "amount",            :precision => 18, :scale => 2
    t.decimal  "credit_amount",     :precision => 18, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_imports", :force => true do |t|
    t.integer  "import_file_id"
    t.string   "voucher_number"
    t.date     "date"
    t.integer  "created_by"
    t.text     "description"
    t.string   "tags"
    t.decimal  "total_amount",    :precision => 18, :scale => 2
    t.integer  "from_account_id"
    t.decimal  "amount",          :precision => 18, :scale => 2
    t.decimal  "credit_amount",   :precision => 18, :scale => 2
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_line_items", :force => true do |t|
    t.integer  "journal_id",                                                      :null => false
    t.integer  "from_account_id",                                                 :null => false
    t.decimal  "amount",          :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "credit_amount",   :precision => 18, :scale => 2, :default => 0.0
  end

  create_table "journal_sequences", :force => true do |t|
    t.integer  "company_id",                      :null => false
    t.integer  "journal_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journal_to_line_items", :force => true do |t|
    t.integer  "journal_id",                                   :null => false
    t.integer  "to_account_id",                                :null => false
    t.decimal  "amount",        :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "journals", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.integer  "account_id"
    t.integer  "created_by",                                                                        :null => false
    t.date     "date"
    t.string   "voucher_number",    :limit => 25
    t.text     "description"
    t.string   "tags"
    t.boolean  "deleted",                                                        :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.decimal  "total_amount",                    :precision => 18, :scale => 2, :default => 0.0
    t.integer  "project_id"
  end

  create_table "labels", :force => true do |t|
    t.integer  "company_id",      :null => false
    t.integer  "created_by",      :null => false
    t.string   "estimate_label"
    t.string   "warehouse_label"
    t.string   "customer_label"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lead_activities", :force => true do |t|
    t.integer  "lead_id"
    t.integer  "activity"
    t.datetime "record_date"
    t.decimal  "time_spent",          :precision => 10, :scale => 0
    t.text     "outcome"
    t.date     "next_followup"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "lead_activity",                                      :default => false
    t.integer  "next_activity"
    t.boolean  "activity_status",                                    :default => false
    t.string   "next_follow_up_time"
    t.date     "completed_date"
  end

  create_table "lead_companies", :force => true do |t|
    t.integer  "lead_id"
    t.integer  "company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leads", :force => true do |t|
    t.string   "name"
    t.string   "mobile",             :limit => 15
    t.string   "email"
    t.integer  "channel_id"
    t.integer  "campaign_id"
    t.date     "next_call_date"
    t.text     "description"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "city"
    t.string   "organisation_name"
    t.text     "notes"
    t.decimal  "estimated_revenue",                :precision => 10, :scale => 2
    t.integer  "probability"
    t.integer  "plan_of_interest"
    t.boolean  "payment_status"
    t.integer  "created_by"
    t.boolean  "deleted",                                                         :default => false
    t.integer  "deleted_by"
    t.integer  "deleted_reason"
    t.integer  "converted_comment"
    t.integer  "converted_by"
    t.integer  "lead_type"
    t.boolean  "converted_to_trial",                                              :default => false
    t.integer  "assigned_to"
    t.integer  "stage"
    t.integer  "trial_status"
    t.integer  "paid_status"
    t.text     "segment"
    t.text     "source"
  end

  create_table "leave_cards", :force => true do |t|
    t.integer  "company_id",                                                                     :null => false
    t.integer  "user_id",                                                                        :null => false
    t.integer  "leave_type_id",                                                                  :null => false
    t.integer  "card_year",          :limit => 2,                                                :null => false
    t.integer  "total_leave_cnt",    :limit => 2,                               :default => 0,   :null => false
    t.decimal  "utilized_leave_cnt",              :precision => 4, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leave_requests", :force => true do |t|
    t.integer  "company_id",                         :null => false
    t.integer  "user_id",                            :null => false
    t.integer  "approved_by"
    t.integer  "leave_type_id",                      :null => false
    t.integer  "leave_status"
    t.date     "start_date"
    t.date     "end_date",                           :null => false
    t.text     "reason_for_leave"
    t.string   "contact_during_leave", :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "approver_comment"
  end

  create_table "leave_types", :force => true do |t|
    t.integer  "company_id",                        :null => false
    t.integer  "created_by",                        :null => false
    t.string   "leave_type"
    t.integer  "allowed_leaves"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "carry",          :default => false, :null => false
    t.boolean  "paid",           :default => true
  end

  create_table "leaves", :force => true do |t|
    t.integer  "company_id",      :null => false
    t.integer  "user_id",         :null => false
    t.integer  "leave_type_id",   :null => false
    t.date     "year"
    t.integer  "leaves_count"
    t.integer  "leaves_utilized"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ledgers", :force => true do |t|
    t.integer  "company_id",                                                                 :null => false
    t.integer  "account_id",                                                                 :null => false
    t.integer  "created_by",                                                                 :null => false
    t.date     "transaction_date",                                                           :null => false
    t.decimal  "debit",                    :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "credit",                   :precision => 18, :scale => 2, :default => 0.0
    t.string   "voucher_number",                                                             :null => false
    t.integer  "voucher_id"
    t.string   "voucher_type"
    t.date     "bank_transaction_date"
    t.text     "description"
    t.boolean  "deleted",                                                 :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.boolean  "reconcilation_status",                                    :default => false
    t.date     "reconcilation_date"
    t.string   "correlate"
    t.integer  "corresponding_account_id"
  end

  add_index "ledgers", ["company_id", "account_id", "transaction_date", "voucher_type", "branch_id"], :name => "ledger_idx"

  create_table "line_items", :force => true do |t|
    t.integer  "voucher_id"
    t.integer  "account_id"
    t.text     "description"
    t.integer  "quantity"
    t.decimal  "unit_cost",             :precision => 10, :scale => 0
    t.decimal  "amount",                :precision => 10, :scale => 0
    t.text     "purchase_order_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loan_accounts", :force => true do |t|
    t.string   "account_number", :limit => 50,                                                :null => false
    t.string   "bank_name",                                                                   :null => false
    t.string   "loan_type"
    t.decimal  "interest_rate",                :precision => 4, :scale => 2, :default => 0.0
    t.string   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "loans_advances_accounts", :force => true do |t|
    t.boolean "interest_applicable"
    t.decimal "interest_rate",       :precision => 4, :scale => 2
    t.integer "compounding_type"
  end

  create_table "login_requests", :force => true do |t|
    t.integer  "company_id"
    t.integer  "created_by"
    t.integer  "status"
    t.string   "calling_action"
    t.integer  "gsp_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "make_payments", :force => true do |t|
    t.date     "payment_date"
    t.decimal  "amount",             :precision => 10, :scale => 2
    t.string   "payment_mode"
    t.integer  "from_account_id"
    t.integer  "paid_to_account_id"
    t.string   "bill_ref"
    t.string   "description"
    t.binary   "send_notification"
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "master_objectives", :force => true do |t|
    t.integer  "company_id",     :null => false
    t.integer  "department_id",  :null => false
    t.integer  "created_by",     :null => false
    t.string   "objective_name"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "description"
    t.integer  "created_by",  :null => false
    t.integer  "user_id",     :null => false
    t.integer  "company_id",  :null => false
    t.integer  "status",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_id"
  end

  create_table "myfiles", :force => true do |t|
    t.integer  "company_id",                 :null => false
    t.integer  "user_id",                    :null => false
    t.integer  "folder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

  add_index "myfiles", ["folder_id"], :name => "index_myfiles_on_folder_id"
  add_index "myfiles", ["user_id"], :name => "index_myfiles_on_user_id"

  create_table "notes", :force => true do |t|
    t.integer  "company_id",  :null => false
    t.integer  "created_by",  :null => false
    t.string   "subject"
    t.text     "description"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organisation_announcements", :force => true do |t|
    t.integer  "company_id",   :null => false
    t.integer  "created_by",   :null => false
    t.string   "title",        :null => false
    t.text     "announcement"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "other_current_assets", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "paid_line_items", :force => true do |t|
    t.integer  "expense_id",                                                  :null => false
    t.integer  "account_id",                                                  :null => false
    t.decimal  "amount",      :precision => 18, :scale => 2, :default => 0.0
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pay_grades", :force => true do |t|
    t.integer  "user_id",                                                     :null => false
    t.integer  "company_id",                                                  :null => false
    t.integer  "job_id",                                                      :null => false
    t.string   "grade_name",                                                  :null => false
    t.text     "description"
    t.decimal  "amount",      :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payheads", :force => true do |t|
    t.integer  "company_id",                                             :null => false
    t.integer  "defined_by",                                             :null => false
    t.string   "payhead_type"
    t.string   "payhead_name"
    t.string   "under"
    t.string   "affect_net_salary"
    t.string   "name_appear_in_payslip"
    t.string   "use_of_gratuity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "optional",                            :default => false
    t.integer  "account_id",                                             :null => false
    t.integer  "calculation_type",       :limit => 2
  end

  create_table "payment_details", :force => true do |t|
    t.integer  "voucher_id",                                                                          :null => false
    t.string   "voucher_type",                                                                        :null => false
    t.decimal  "amount",                              :precision => 18, :scale => 2, :default => 0.0
    t.date     "payment_date",                                                                        :null => false
    t.string   "account_number",        :limit => 16
    t.string   "bank_name"
    t.string   "transaction_reference", :limit => 50
    t.string   "branch"
    t.string   "type",                                                                                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payment_details", ["voucher_id", "voucher_type"], :name => "paydet_vchrid_vchrtyp_idex"

  create_table "payment_gateways", :force => true do |t|
    t.string   "name",                           :null => false
    t.string   "key",                            :null => false
    t.string   "api_key"
    t.string   "vanity_url",                     :null => false
    t.string   "gateway_url",                    :null => false
    t.boolean  "production",  :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_transactions", :force => true do |t|
    t.integer  "company_id"
    t.integer  "transaction_status"
    t.string   "transaction_reference"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "issuer_ref_num"
    t.string   "auth_ID_code"
    t.string   "transaction_msg"
    t.string   "gateway_transaction_num"
    t.string   "gateway_transaction_status"
    t.string   "gateway_transaction_ref"
    t.integer  "billing_invoice_id"
    t.string   "signature"
  end

  create_table "payment_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                              :null => false
    t.integer  "payment_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_vouchers", :force => true do |t|
    t.integer  "company_id",                                                                                 :null => false
    t.integer  "purchase_id"
    t.integer  "created_by",                                                                                 :null => false
    t.string   "voucher_number",             :limit => 32,                                                   :null => false
    t.date     "voucher_date",                                                                               :null => false
    t.date     "payment_date",                                                                               :null => false
    t.integer  "from_account_id",                                                                            :null => false
    t.integer  "to_account_id",                                                                              :null => false
    t.decimal  "amount",                                   :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.text     "description"
    t.boolean  "deleted",                                                                 :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.integer  "branch_id"
    t.integer  "tds_account_id"
    t.decimal  "tds_amount",                               :precision => 18, :scale => 2, :default => 0.0
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                            :precision => 18, :scale => 5, :default => 0.0
    t.integer  "expense_id"
    t.boolean  "advanced",                                                                :default => false
    t.boolean  "allocated"
    t.integer  "voucher_type",                                                            :default => 0
  end

  create_table "payments", :force => true do |t|
    t.date     "payment_date"
    t.decimal  "amount",                :precision => 10, :scale => 2
    t.string   "payment_mode"
    t.integer  "cheque_number"
    t.date     "cheque_date"
    t.string   "bank"
    t.string   "branch"
    t.integer  "transaction_id"
    t.date     "card_transaction_date"
    t.string   "type_of_credit_card"
    t.string   "card_number"
    t.integer  "from_account_id"
    t.integer  "paid_to_account_id"
    t.string   "bill_ref"
    t.string   "description"
    t.integer  "ledger_id"
    t.string   "voucher_number"
    t.integer  "company_id"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "payroll_details", :force => true do |t|
    t.integer  "company_id"
    t.date     "month"
    t.integer  "status",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
  end

  create_table "payroll_execution_jobs", :force => true do |t|
    t.integer  "company_id"
    t.date     "execution_date"
    t.boolean  "status",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.integer  "payroll_detail_id"
  end

  create_table "payroll_settings", :force => true do |t|
    t.integer  "company_id"
    t.boolean  "enable_payslip_signatory", :default => false
    t.string   "payslip_footer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pbreferrals", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.integer  "invited_by",                                                                        :null => false
    t.integer  "coupon_id",                                                                         :null => false
    t.string   "name"
    t.string   "email",              :limit => 100,                                                 :null => false
    t.integer  "status",                                                           :default => 0
    t.string   "token",                                                                             :null => false
    t.decimal  "earning",                           :precision => 18, :scale => 2, :default => 0.0
    t.integer  "invitee_company_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plan_properties", :force => true do |t|
    t.integer  "plan_id"
    t.string   "name",       :limit => 50
    t.string   "value",      :limit => 50
    t.string   "datatype",   :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", :force => true do |t|
    t.string   "name"
    t.decimal  "price",            :precision => 18, :scale => 2, :default => 0.0
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_name"
    t.integer  "user_count"
    t.decimal  "storage_limit_mb", :precision => 10, :scale => 0
    t.boolean  "active",                                          :default => false
  end

  create_table "policy_documents", :force => true do |t|
    t.integer  "company_id",                 :null => false
    t.integer  "user_id",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

  add_index "policy_documents", ["company_id"], :name => "index_policy_documents_on_company_id"
  add_index "policy_documents", ["user_id"], :name => "index_policy_documents_on_user_id"

  create_table "process_payrolls", :force => true do |t|
    t.integer  "user_id"
    t.integer  "company_id"
    t.string   "month"
    t.integer  "attendance"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_batches", :force => true do |t|
    t.integer  "product_id"
    t.integer  "warehouse_id"
    t.string   "batch_number"
    t.decimal  "quantity",                   :precision => 10, :scale => 2, :default => 0.0
    t.date     "manufacture_date"
    t.date     "expiry_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "reference"
    t.integer  "stock_receipt_line_item_id"
    t.decimal  "opening_stock_unit_price",   :precision => 18, :scale => 2
    t.boolean  "opening_batch",                                             :default => false
  end

  create_table "product_histories", :force => true do |t|
    t.integer  "company_id"
    t.integer  "product_id"
    t.integer  "financial_year_id"
    t.decimal  "opening_stock",     :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "unit_value",        :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_imports", :force => true do |t|
    t.integer  "import_file_id"
    t.string   "name"
    t.string   "description"
    t.string   "warehouse"
    t.string   "quantity"
    t.string   "batch_no"
    t.string   "unit_price"
    t.string   "reorder_level"
    t.string   "unit_of_measure"
    t.string   "sales_price"
    t.string   "income_account"
    t.string   "purchase_price"
    t.string   "expense_account"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_pricing_levels", :force => true do |t|
    t.integer  "company_id"
    t.string   "caption"
    t.decimal  "discount_percent", :precision => 5, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "product_settings", :force => true do |t|
    t.integer  "company_id"
    t.boolean  "multilevel_pricing", :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", :force => true do |t|
    t.integer  "company_id",                                                           :null => false
    t.integer  "account_id"
    t.integer  "created_by",                                                           :null => false
    t.string   "name",                                                                 :null => false
    t.string   "unit_of_measure"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "average_price",      :precision => 10, :scale => 0, :default => 0
    t.integer  "branch_id"
    t.text     "description"
    t.string   "type"
    t.decimal  "purchase_price",     :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "sales_price",        :precision => 18, :scale => 2, :default => 0.0
    t.integer  "expense_account_id"
    t.integer  "income_account_id"
    t.decimal  "reorder_level",      :precision => 10, :scale => 2, :default => 0.0
    t.boolean  "inventory"
    t.boolean  "batch_enable",                                      :default => false
    t.string   "product_code"
    t.date     "as_on"
    t.string   "hsn_code"
  end

  create_table "profitbooks_workstreams", :force => true do |t|
    t.integer "feature_id",                  :null => false
    t.string  "icon_code",    :limit => 150, :null => false
    t.date    "release_date",                :null => false
    t.string  "title",                       :null => false
    t.text    "details"
    t.string  "link_URL"
    t.integer "created_by",   :limit => 2,   :null => false
    t.integer "status",       :limit => 1,   :null => false
  end

  create_table "projects", :force => true do |t|
    t.integer  "company_id",                                                       :null => false
    t.integer  "created_by",                                                       :null => false
    t.string   "name"
    t.date     "start_date"
    t.date     "end_date"
    t.decimal  "estimated_cost", :precision => 18, :scale => 2, :default => 0.0
    t.text     "description"
    t.boolean  "status",                                        :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "closed_by"
    t.integer  "branch_id"
  end

  create_table "provision_accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_accounts", :force => true do |t|
    t.boolean  "inventoriable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.decimal  "unit_cost",        :precision => 10, :scale => 2, :default => 0.0
    t.boolean  "reseller_product",                                :default => false
    t.decimal  "sell_cost",        :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "purchase_attachments", :force => true do |t|
    t.integer  "company_id",                 :null => false
    t.integer  "user_id",                    :null => false
    t.string   "purchase_id",                :null => false
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_debit_allocations", :force => true do |t|
    t.integer  "purchase_id"
    t.integer  "debit_note_id"
    t.decimal  "amount",        :precision => 18, :scale => 2
    t.boolean  "deleted",                                      :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_line_items", :force => true do |t|
    t.integer  "purchase_id",                                                                :null => false
    t.integer  "account_id"
    t.decimal  "quantity",                 :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "unit_rate",                :precision => 18, :scale => 4
    t.string   "purchase_order_reference"
    t.string   "cost_center"
    t.boolean  "tax",                                                     :default => false
    t.decimal  "amount",                   :precision => 18, :scale => 2, :default => 0.0
    t.text     "description"
    t.boolean  "deleted"
    t.integer  "deleted_by"
    t.integer  "approved_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "warehouse_id"
    t.integer  "product_id"
    t.integer  "tax_account_id"
    t.decimal  "discount_percent",         :precision => 5,  :scale => 2
    t.string   "eligibility"
    t.decimal  "igst",                     :precision => 10, :scale => 0
    t.decimal  "sgst",                     :precision => 10, :scale => 0
    t.decimal  "cgst",                     :precision => 10, :scale => 0
  end

  add_index "purchase_line_items", ["product_id"], :name => "pur_ln_item_product_idx"

  create_table "purchase_order_line_items", :force => true do |t|
    t.integer  "purchase_order_id"
    t.integer  "account_id"
    t.decimal  "quantity",          :precision => 10, :scale => 2
    t.decimal  "unit_rate",         :precision => 18, :scale => 4
    t.string   "cost_center"
    t.boolean  "tax"
    t.decimal  "amount",            :precision => 18, :scale => 2
    t.text     "description"
    t.boolean  "deleted"
    t.boolean  "deleted_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "line_item_type"
    t.integer  "product_id"
    t.integer  "tax_account_id"
    t.decimal  "discount_percent",  :precision => 5,  :scale => 2
  end

  create_table "purchase_order_sequences", :force => true do |t|
    t.integer  "company_id",                             :null => false
    t.integer  "purchase_order_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_order_taxes", :force => true do |t|
    t.integer  "purchase_order_line_item_id", :null => false
    t.integer  "account_id",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", :force => true do |t|
    t.integer  "company_id",                                                                   :null => false
    t.integer  "created_by",                                                                   :null => false
    t.string   "purchase_order_number"
    t.integer  "account_id",                                                                   :null => false
    t.date     "po_date"
    t.date     "record_date",                                                                  :null => false
    t.string   "bill_reference"
    t.integer  "status"
    t.boolean  "deleted",                                                   :default => false
    t.integer  "deleted_by"
    t.text     "customer_notes"
    t.text     "terms_and_conditions"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.integer  "branch_id"
    t.decimal  "total_amount",               :precision => 18, :scale => 2, :default => 0.0
    t.integer  "currency_id"
    t.decimal  "exchange_rate",              :precision => 18, :scale => 5, :default => 0.0
    t.integer  "project_id"
    t.boolean  "gst_purchaseorder",                                         :default => false
    t.date     "due_date"
  end

  create_table "purchase_return_line_items", :force => true do |t|
    t.integer  "purchase_return_id",                                                      :null => false
    t.integer  "account_id"
    t.decimal  "quantity",              :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "unit_rate",             :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "tax",                                                  :default => false
    t.decimal  "amount",                :precision => 18, :scale => 2, :default => 0.0
    t.string   "line_type"
    t.integer  "product_id"
    t.integer  "tax_account_id"
    t.decimal  "discount_percent",      :precision => 8,  :scale => 2
    t.integer  "warehouse_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchase_line_item_id"
  end

  create_table "purchase_return_sequences", :force => true do |t|
    t.integer  "company_id",                              :null => false
    t.integer  "purchase_return_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_return_taxes", :force => true do |t|
    t.integer  "purchase_return_line_item_id", :null => false
    t.integer  "account_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_returns", :force => true do |t|
    t.integer  "company_id",                                                             :null => false
    t.integer  "purchase_id",                                                            :null => false
    t.integer  "created_by",                                                             :null => false
    t.string   "purchase_return_number"
    t.integer  "account_id",                                                             :null => false
    t.date     "record_date"
    t.text     "customer_notes"
    t.decimal  "total_amount",           :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "decimal",                :precision => 18, :scale => 5, :default => 0.0
    t.integer  "currency_id"
    t.decimal  "exchange_rate",          :precision => 18, :scale => 5, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "warehouse_id"
    t.integer  "branch_id"
  end

  create_table "purchase_sequences", :force => true do |t|
    t.integer  "company_id",                       :null => false
    t.integer  "purchase_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_taxes", :force => true do |t|
    t.integer  "purchase_line_item_id", :null => false
    t.integer  "account_id",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_warehouse_details", :force => true do |t|
    t.integer  "purchase_line_item_id"
    t.integer  "warehouse_id"
    t.decimal  "quantity",              :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "product_batch_id"
    t.boolean  "status_id",                                            :default => true
    t.integer  "product_id"
    t.boolean  "deleted",                                              :default => false
  end

  create_table "purchases", :force => true do |t|
    t.integer  "company_id",                                                                                :null => false
    t.integer  "created_by",                                                                                :null => false
    t.string   "purchase_number"
    t.integer  "account_id"
    t.date     "bill_date"
    t.date     "record_date"
    t.date     "due_date"
    t.string   "bill_reference"
    t.boolean  "deleted",                                                                :default => false
    t.text     "customer_notes"
    t.text     "terms_and_conditions"
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.integer  "project_id"
    t.integer  "branch_id"
    t.integer  "status_id"
    t.string   "custom_field1"
    t.string   "custom_field2"
    t.string   "custom_field3"
    t.boolean  "stock_receipt",                                                          :default => true
    t.decimal  "total_amount",                            :precision => 18, :scale => 2, :default => 0.0
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                           :precision => 18, :scale => 5, :default => 0.0
    t.integer  "purchase_order_id"
    t.boolean  "tax_inclusive",                                                          :default => false
    t.decimal  "outstanding",                             :precision => 18, :scale => 2
    t.integer  "settlement_account_id"
    t.decimal  "settlement_exchange_rate",                :precision => 18, :scale => 5, :default => 0.0
    t.decimal  "settled_amount",                          :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "gst_purchase"
    t.integer  "reverse_charge",             :limit => 1,                                :default => 0,     :null => false
    t.boolean  "import_purchase",                                                        :default => false
    t.date     "boe_date"
    t.string   "boe_num"
    t.decimal  "boe_value",                               :precision => 10, :scale => 0
  end

  create_table "purchases_payments", :force => true do |t|
    t.integer  "payment_voucher_id"
    t.integer  "purchase_id"
    t.decimal  "amount",             :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "tds_amount",         :precision => 18, :scale => 2, :default => 0.0
    t.boolean  "deleted",                                           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receipt_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                              :null => false
    t.integer  "receipt_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receipt_vouchers", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.integer  "invoice_id"
    t.integer  "created_by",                                                                        :null => false
    t.string   "voucher_number",    :limit => 32,                                                   :null => false
    t.date     "voucher_date",                                                                      :null => false
    t.date     "received_date",                                                                     :null => false
    t.integer  "from_account_id",                                                                   :null => false
    t.integer  "to_account_id",                                                                     :null => false
    t.decimal  "amount",                          :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.text     "description"
    t.boolean  "deleted",                                                        :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "branch_id"
    t.integer  "tds_account_id"
    t.decimal  "tds_amount",                      :precision => 18, :scale => 2, :default => 0.0
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                   :precision => 18, :scale => 5, :default => 0.0
    t.boolean  "advanced",                                                       :default => false
    t.boolean  "allocated"
  end

  create_table "receive_cashes", :force => true do |t|
    t.date     "received_date"
    t.decimal  "amount",                :precision => 10, :scale => 2
    t.string   "receipt_mode"
    t.integer  "from_account_id"
    t.integer  "deposit_to_account_id"
    t.string   "description"
    t.binary   "send_thank_you_mail"
    t.integer  "cheque_number"
    t.date     "cheque_date"
    t.string   "bank"
    t.string   "branch"
    t.integer  "transaction_id"
    t.date     "transaction_date"
    t.string   "type_of_credit_card"
    t.string   "card_number"
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "receive_moneys", :force => true do |t|
    t.integer  "company_id"
    t.string   "voucher_number",                                                        :null => false
    t.date     "received_date",                                                         :null => false
    t.decimal  "amount",                :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.string   "receipt_mode"
    t.integer  "from_account_id",                                                       :null => false
    t.integer  "deposit_to_account_id",                                                 :null => false
    t.string   "description"
    t.binary   "send_thank_you_mail"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recursions", :force => true do |t|
    t.integer  "company_id"
    t.integer  "recursive_id"
    t.string   "recursive_type"
    t.date     "schedule_on"
    t.integer  "frequency"
    t.integer  "iteration"
    t.integer  "utilized_iteration"
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recursive_invoices", :force => true do |t|
    t.integer  "invoice_id"
    t.integer  "recursion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "invoice_date", :default => '2013-07-21'
  end

  create_table "reimbursement_note_attachments", :force => true do |t|
    t.integer  "company_id",                 :null => false
    t.integer  "user_id",                    :null => false
    t.string   "reimbursement_note_id",      :null => false
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reimbursement_note_line_items", :force => true do |t|
    t.integer  "reimbursement_note_id",                                                 :null => false
    t.text     "description"
    t.decimal  "amount",                :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "expense_account_id",                                                    :null => false
  end

  create_table "reimbursement_note_sequences", :force => true do |t|
    t.integer  "company_id",                                 :null => false
    t.integer  "reimbursement_note_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reimbursement_notes", :force => true do |t|
    t.integer  "company_id",                                                                  :null => false
    t.string   "reimbursement_note_number",                                                   :null => false
    t.date     "transaction_date",                                                            :null => false
    t.integer  "from_account_id",                                                             :null => false
    t.integer  "branch_id"
    t.text     "description"
    t.decimal  "amount",                    :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.boolean  "submitted",                                                :default => false
    t.integer  "created_by",                                                                  :null => false
    t.boolean  "deleted",                                                  :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reimbursement_voucher_id"
    t.integer  "expense_id"
  end

  create_table "reimbursement_voucher_line_items", :force => true do |t|
    t.integer  "reimbursement_voucher_id",                                                 :null => false
    t.integer  "reimbursement_note_id",                                                    :null => false
    t.decimal  "payment_amount",           :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reimbursement_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                                    :null => false
    t.integer  "reimbursement_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reimbursement_vouchers", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.integer  "branch_id"
    t.integer  "created_by",                                                                        :null => false
    t.string   "voucher_number",    :limit => 32,                                                   :null => false
    t.date     "voucher_date",                                                                      :null => false
    t.date     "received_date",                                                                     :null => false
    t.integer  "from_account_id",                                                                   :null => false
    t.integer  "to_account_id",                                                                     :null => false
    t.decimal  "amount",                          :precision => 18, :scale => 2, :default => 0.0,   :null => false
    t.text     "description"
    t.boolean  "deleted",                                                        :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "request_logs", :force => true do |t|
    t.integer  "txn_id",          :null => false
    t.integer  "gsp_id",          :null => false
    t.integer  "gsp_detail_id",   :null => false
    t.integer  "company_id",      :null => false
    t.integer  "status"
    t.text     "request_payload"
    t.string   "remote_user_ip"
    t.datetime "timestamp_field"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reserves_and_surplus_accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "response_logs", :force => true do |t|
    t.integer  "txn_id",           :null => false
    t.integer  "request_log_id",   :null => false
    t.text     "response_payload"
    t.string   "remote_user_ip"
    t.datetime "timestamp_field"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights", :force => true do |t|
    t.string   "resource"
    t.string   "operation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.integer  "plan_id"
    t.string   "name",       :limit => 100, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "desc"
  end

  create_table "sac_headings", :force => true do |t|
    t.integer  "heading_index"
    t.string   "heading"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saccounting_line_items", :force => true do |t|
    t.integer  "saccounting_id",                                                  :null => false
    t.integer  "from_account_id",                                                 :null => false
    t.decimal  "amount",          :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saccounting_sequences", :force => true do |t|
    t.integer  "company_id",                          :null => false
    t.integer  "saccounting_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saccounting_to_line_items", :force => true do |t|
    t.integer  "saccounting_id",                                :null => false
    t.integer  "to_account_id",                                 :null => false
    t.decimal  "amount",         :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "saccountings", :force => true do |t|
    t.integer  "company_id",                                                                        :null => false
    t.integer  "account_id",                                                                        :null => false
    t.integer  "created_by",                                                                        :null => false
    t.date     "voucher_date",                                                                      :null => false
    t.string   "voucher_number",    :limit => 25,                                                   :null => false
    t.text     "description"
    t.string   "tags"
    t.boolean  "deleted",                                                        :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.decimal  "total_amount",                    :precision => 18, :scale => 2, :default => 0.0
  end

  create_table "salaries", :force => true do |t|
    t.integer  "company_id",                                   :null => false
    t.integer  "user_id",                                      :null => false
    t.integer  "attendance_id",                                :null => false
    t.integer  "payhead_id",                                   :null => false
    t.decimal  "amount",        :precision => 18, :scale => 2
    t.date     "month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salary_computation_results", :force => true do |t|
    t.integer  "company_id",                                                             :null => false
    t.integer  "user_id",                                                                :null => false
    t.integer  "attendance_id",                                                          :null => false
    t.integer  "payhead_id",                                                             :null => false
    t.decimal  "amount",                   :precision => 18, :scale => 2
    t.date     "month",                                                                  :null => false
    t.integer  "processed_by"
    t.integer  "status",                                                  :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",                                                             :null => false
    t.integer  "payroll_execution_job_id",                                               :null => false
    t.integer  "payroll_detail_id",                                                      :null => false
  end

  create_table "salary_structure_histories", :force => true do |t|
    t.integer  "salary_structure_id"
    t.integer  "company_id"
    t.integer  "for_employee"
    t.integer  "created_by"
    t.date     "effective_from_date"
    t.date     "updated_on_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salary_structure_history_line_items", :force => true do |t|
    t.integer  "salary_structure_history_id"
    t.integer  "payhead_id"
    t.decimal  "amount",                      :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salary_structure_line_items", :force => true do |t|
    t.integer  "salary_structure_id",                                                 :null => false
    t.integer  "payhead_id",                                                          :null => false
    t.decimal  "amount",              :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "salary_structures", :force => true do |t|
    t.integer  "company_id"
    t.integer  "for_employee"
    t.integer  "created_by"
    t.integer  "pay_head"
    t.integer  "pay_head_type"
    t.date     "effective_from_date"
    t.decimal  "amount",              :precision => 18, :scale => 2
    t.decimal  "total",               :precision => 18, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "valid_till_date"
  end

  create_table "sales_accounts", :force => true do |t|
    t.boolean  "inventoriable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.decimal  "unit_cost",     :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "sell_cost",     :precision => 10, :scale => 2, :default => 0.0
  end

  create_table "sales_order_line_items", :force => true do |t|
    t.integer  "sales_order_id",                                                 :null => false
    t.integer  "product_id"
    t.integer  "account_id"
    t.integer  "tax_account_id"
    t.decimal  "quantity",       :precision => 10, :scale => 2
    t.decimal  "unit_rate",      :precision => 18, :scale => 4
    t.decimal  "discount",       :precision => 4,  :scale => 2
    t.text     "description"
    t.string   "line_item_type"
    t.decimal  "amount",         :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_order_sequences", :force => true do |t|
    t.integer  "company_id"
    t.integer  "sales_order_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_order_taxes", :force => true do |t|
    t.integer  "sales_order_line_item_id", :null => false
    t.integer  "account_id",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sales_orders", :force => true do |t|
    t.integer  "company_id",                                                                          :null => false
    t.integer  "account_id"
    t.integer  "created_by",                                                                          :null => false
    t.string   "voucher_number"
    t.date     "voucher_date",                                                                        :null => false
    t.integer  "status",                                                           :default => 4
    t.decimal  "total_amount",                      :precision => 18, :scale => 2, :default => 0.0
    t.text     "customer_notes"
    t.text     "terms_and_conditions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "billing_status",                                                   :default => 0
    t.integer  "customer_id"
    t.integer  "branch_id"
    t.integer  "estimate_id"
    t.integer  "currency_id"
    t.decimal  "exchange_rate",                     :precision => 18, :scale => 5, :default => 0.0
    t.integer  "project_id"
    t.string   "po_reference"
    t.date     "po_date"
    t.boolean  "gst_salesorder",                                                   :default => false
    t.string   "place_of_supply",      :limit => 3
  end

  create_table "sales_warehouse_details", :force => true do |t|
    t.integer  "invoice_line_item_id"
    t.integer  "warehouse_id"
    t.decimal  "quantity",             :precision => 10, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_batch_id"
    t.integer  "product_id"
    t.boolean  "draft",                                               :default => false
  end

  create_table "secured_loan_accounts", :force => true do |t|
    t.string   "account_number", :limit => 50,                                                :null => false
    t.string   "bank_name",                                                                   :null => false
    t.string   "loan_type"
    t.decimal  "interest_rate",                :precision => 4, :scale => 2, :default => 0.0
    t.string   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sharable_documents", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "folder_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "uploaded_file_file_name"
    t.string   "uploaded_file_content_type"
    t.integer  "uploaded_file_file_size"
    t.datetime "uploaded_file_updated_at"
  end

  add_index "sharable_documents", ["folder_id"], :name => "index_sharable_documents_on_folder_id"
  add_index "sharable_documents", ["user_id"], :name => "index_sharable_documents_on_user_id"

  create_table "shared_folders", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.string   "shared_email"
    t.integer  "shared_user_id"
    t.integer  "folder_id"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shared_folders", ["folder_id"], :name => "index_shared_folders_on_folder_id"
  add_index "shared_folders", ["shared_user_id"], :name => "index_shared_folders_on_shared_user_id"
  add_index "shared_folders", ["user_id"], :name => "index_shared_folders_on_user_id"

  create_table "simple_captcha_data", :force => true do |t|
    t.string   "key",        :limit => 40
    t.string   "value",      :limit => 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], :name => "idx_key"

  create_table "states", :force => true do |t|
    t.integer "country_id", :null => false
    t.string  "code",       :null => false
    t.string  "name",       :null => false
    t.string  "state_type"
    t.integer "state_code"
    t.string  "capital"
  end

  create_table "stock_histories", :force => true do |t|
    t.integer  "company_id"
    t.integer  "stock_id"
    t.integer  "financial_year_id"
    t.decimal  "opening_stock",       :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "opening_stock_value", :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_issue_line_items", :force => true do |t|
    t.integer  "stock_issue_voucher_id",                                :null => false
    t.integer  "product_id",                                            :null => false
    t.decimal  "quantity",               :precision => 10, :scale => 2, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_batch_id"
  end

  add_index "stock_issue_line_items", ["product_id"], :name => "stk_issu_ln_item_product_idx"

  create_table "stock_issue_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                                  :null => false
    t.integer  "stock_issue_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_issue_vouchers", :force => true do |t|
    t.integer  "company_id",     :null => false
    t.integer  "warehouse_id"
    t.string   "voucher_number", :null => false
    t.date     "voucher_date",   :null => false
    t.integer  "issued_to"
    t.integer  "created_by",     :null => false
    t.string   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.string   "custom_field1"
    t.string   "custom_field2"
    t.string   "custom_field3"
  end

  create_table "stock_ledgers", :force => true do |t|
    t.integer  "company_id",                                                           :null => false
    t.integer  "product_id",                                                           :null => false
    t.integer  "voucher_id",                                                           :null => false
    t.string   "voucher_type",                                                         :null => false
    t.integer  "voucher_line_item_id"
    t.integer  "warehouse_id",                                                         :null => false
    t.integer  "branch_id"
    t.datetime "transaction_date",                                                     :null => false
    t.decimal  "credit_quantity",      :precision => 10, :scale => 0, :default => 0
    t.decimal  "debit_quantity",       :precision => 10, :scale => 0, :default => 0
    t.integer  "created_by",                                                           :null => false
    t.decimal  "unit_price",           :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_receipt_line_items", :force => true do |t|
    t.integer  "stock_receipt_voucher_id",                                                 :null => false
    t.integer  "product_id",                                                               :null => false
    t.decimal  "quantity",                 :precision => 10, :scale => 2,                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_rate",                :precision => 18, :scale => 2, :default => 0.0
  end

  add_index "stock_receipt_line_items", ["product_id"], :name => "stk_rcpt_ln_item_product_idx"

  create_table "stock_receipt_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                                    :null => false
    t.integer  "stock_receipt_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_receipt_vouchers", :force => true do |t|
    t.integer  "company_id",     :null => false
    t.integer  "warehouse_id"
    t.string   "voucher_number", :null => false
    t.date     "voucher_date",   :null => false
    t.integer  "received_by"
    t.string   "details"
    t.integer  "created_by",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
    t.string   "custom_field1"
    t.string   "custom_field2"
    t.string   "custom_field3"
    t.integer  "purchase_id"
  end

  create_table "stock_transfer_line_items", :force => true do |t|
    t.integer  "stock_transfer_voucher_id",                                :null => false
    t.integer  "product_id",                                               :null => false
    t.decimal  "available_quantity",        :precision => 10, :scale => 2
    t.decimal  "transfer_quantity",         :precision => 10, :scale => 2, :null => false
    t.integer  "destination_warehouse_id",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_batch_id"
  end

  create_table "stock_transfer_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                                     :null => false
    t.integer  "stock_transfer_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_transfer_vouchers", :force => true do |t|
    t.integer  "company_id",     :null => false
    t.integer  "created_by",     :null => false
    t.integer  "warehouse_id",   :null => false
    t.string   "voucher_number", :null => false
    t.string   "details"
    t.date     "transfer_date"
    t.date     "voucher_date"
    t.integer  "branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_wastage_line_items", :force => true do |t|
    t.integer  "stock_wastage_voucher_id",                                :null => false
    t.integer  "product_id",                                              :null => false
    t.decimal  "quantity",                 :precision => 10, :scale => 2
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_batch_id"
  end

  add_index "stock_wastage_line_items", ["product_id"], :name => "stk_wast_ln_item_product_idx"

  create_table "stock_wastage_voucher_sequences", :force => true do |t|
    t.integer  "company_id",                                    :null => false
    t.integer  "stock_wastage_voucher_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stock_wastage_vouchers", :force => true do |t|
    t.integer  "company_id",                        :null => false
    t.integer  "warehouse_id",                      :null => false
    t.string   "voucher_number"
    t.datetime "voucher_date"
    t.integer  "branch_id"
    t.integer  "created_by",                        :null => false
    t.boolean  "deleted",        :default => false
    t.integer  "deleted_by"
    t.string   "deleted_reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "custom_field1"
    t.string   "custom_field2"
    t.string   "custom_field3"
  end

  create_table "stocks", :force => true do |t|
    t.integer  "company_id",                                                               :null => false
    t.integer  "warehouse_id",                                                             :null => false
    t.integer  "product_id",                                                               :null => false
    t.decimal  "quantity",                 :precision => 10, :scale => 2, :default => 0.0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "opening_stock",            :precision => 10, :scale => 2, :default => 0.0
    t.decimal  "opening_stock_unit_price", :precision => 10, :scale => 2
  end

  add_index "stocks", ["product_id"], :name => "stks_product_idx"

  create_table "subscription_histories", :force => true do |t|
    t.integer  "company_id"
    t.integer  "plan_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "renewal_date"
    t.datetime "first_subscription_date"
    t.string   "ip_address"
    t.decimal  "amount",                  :precision => 18, :scale => 2
    t.decimal  "allocated_storage_mb",    :precision => 10, :scale => 0
    t.integer  "allocated_user_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "company_id"
    t.integer  "plan_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "status"
    t.datetime "renewal_date"
    t.datetime "first_subscription_date"
    t.string   "ip_address"
    t.decimal  "amount",                  :precision => 18, :scale => 0, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "allocated_storage_mb",    :precision => 10, :scale => 0
    t.decimal  "utilized_storage_mb",     :precision => 10, :scale => 0
    t.integer  "allocated_user_count"
    t.integer  "utilized_user_count"
    t.integer  "status_id"
    t.string   "token"
  end

  add_index "subscriptions", ["company_id"], :name => "subs_company_idx"

  create_table "sundry_creditors", :force => true do |t|
    t.string   "contact_number"
    t.string   "email"
    t.string   "PAN",                :limit => 10
    t.string   "sales_tax_number",   :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tan",                :limit => 25
    t.string   "vat_tin",            :limit => 25
    t.string   "cst",                :limit => 25
    t.string   "excise_reg_no",      :limit => 25
    t.string   "service_tax_reg_no", :limit => 25
  end

  create_table "sundry_debtors", :force => true do |t|
    t.string   "contact_number"
    t.string   "email"
    t.string   "PAN",                      :limit => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tan",                      :limit => 25
    t.string   "vat_tin",                  :limit => 25
    t.string   "cst",                      :limit => 25
    t.string   "excise_reg_no",            :limit => 25
    t.string   "service_tax_reg_no",       :limit => 25
    t.string   "website"
    t.string   "fax",                      :limit => 12
    t.string   "country",                  :limit => 100
    t.string   "weekly_off",               :limit => 50
    t.string   "cin_code",                 :limit => 25
    t.string   "bank_name"
    t.string   "ifsc_code",                :limit => 25
    t.string   "micr_code",                :limit => 25
    t.string   "bsr_code",                 :limit => 25
    t.integer  "credit_days"
    t.integer  "credit_limit"
    t.date     "date_of_incorporation"
    t.string   "open_time",                :limit => 10
    t.string   "close_time",               :limit => 10
    t.string   "notes"
    t.integer  "product_pricing_level_id"
  end

  create_table "super_users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "email"
    t.string   "hashed_password"
    t.string   "salt"
    t.string   "role"
    t.boolean  "active"
    t.datetime "last_login"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "supports", :force => true do |t|
    t.integer  "company_id",                                :null => false
    t.string   "subject"
    t.text     "description"
    t.integer  "created_by",                                :null => false
    t.date     "created_date"
    t.string   "assigned_to"
    t.integer  "status_id",                                 :null => false
    t.date     "completed_date"
    t.string   "ticket_number",                             :null => false
    t.boolean  "deleted",                :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "resolution_description"
    t.integer  "reply_id"
  end

  create_table "suspense_accounts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "taggings_count", :default => 0
  end

  create_table "tasks", :force => true do |t|
    t.integer  "company_id",       :null => false
    t.integer  "user_id",          :null => false
    t.integer  "created_by",       :null => false
    t.integer  "assigned_to",      :null => false
    t.string   "description"
    t.date     "due_date"
    t.integer  "priority"
    t.integer  "task_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "billable"
    t.integer  "project_id"
    t.integer  "sales_account_id"
    t.date     "completed_date"
  end

  create_table "tds_payment_vouchers", :force => true do |t|
    t.integer  "company_id",                                                      :null => false
    t.integer  "created_by",                                                      :null => false
    t.integer  "branch_id"
    t.date     "payment_date"
    t.string   "tan_no",                                                          :null => false
    t.integer  "assessment_year",                                                 :null => false
    t.integer  "tds_account_id",                                                  :null => false
    t.integer  "account_id",                                                      :null => false
    t.string   "cin_no"
    t.string   "bsr_code"
    t.string   "challan_no"
    t.decimal  "basic_tax",       :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "decimal",         :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "surcharge",       :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "edu_cess",        :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "other",           :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "penalty",         :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "interest",        :precision => 18, :scale => 2, :default => 0.0
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "template_margins", :force => true do |t|
    t.integer  "template_id"
    t.integer  "hide_logo",                                       :default => 0
    t.integer  "hide_address",                                    :default => 0
    t.decimal  "top_margin",       :precision => 10, :scale => 0, :default => 10
    t.decimal  "left_margin",      :precision => 10, :scale => 0, :default => 10
    t.decimal  "right_margin",     :precision => 10, :scale => 0, :default => 20
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id",                                                      :null => false
    t.integer  "HideRateQuantity",                                :default => 1
  end

  create_table "templates", :force => true do |t|
    t.string   "template_name"
    t.string   "voucher_type",                     :null => false
    t.boolean  "deleted",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timesheet_line_items", :force => true do |t|
    t.integer  "timesheet_id",                                :null => false
    t.integer  "task_id",                                     :null => false
    t.decimal  "timestamp",    :precision => 10, :scale => 0
    t.date     "day"
    t.integer  "holiday_id"
    t.integer  "leave_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timesheets", :force => true do |t|
    t.integer  "company_id",  :null => false
    t.integer  "user_id",     :null => false
    t.date     "start_date"
    t.date     "end_date"
    t.date     "record_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_sequences", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transfer_cash_sequences", :force => true do |t|
    t.integer  "company_id",                            :null => false
    t.integer  "transfer_cash_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transfer_cashes", :force => true do |t|
    t.integer  "company_id",                                                            :null => false
    t.integer  "created_by",                                                            :null => false
    t.date     "transaction_date",                                                      :null => false
    t.decimal  "amount",              :precision => 18, :scale => 2, :default => 0.0
    t.integer  "transferred_from_id",                                                   :null => false
    t.integer  "transferred_to_id",                                                     :null => false
    t.string   "description"
    t.string   "voucher_number"
    t.boolean  "deleted",                                            :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "transfer_moneys", :force => true do |t|
    t.integer  "company_id",                                                       :null => false
    t.string   "voucher_number",                                                   :null => false
    t.date     "transaction_date",                                                 :null => false
    t.decimal  "amount",           :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.integer  "from_account_id",                                                  :null => false
    t.integer  "to_account_id",                                                    :null => false
    t.string   "description"
    t.integer  "created_by",                                                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unsecured_loan_accounts", :force => true do |t|
    t.string   "entity_name",                                                  :null => false
    t.string   "loan_type"
    t.decimal  "interest_rate", :precision => 4, :scale => 2, :default => 0.0
    t.string   "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_informations", :force => true do |t|
    t.integer  "user_id",              :null => false
    t.string   "gender"
    t.date     "birth_date"
    t.string   "emergency_contact"
    t.string   "marital_status"
    t.string   "passport_number"
    t.date     "passport_expiry_date"
    t.date     "marriage_date"
    t.string   "blood_group"
    t.string   "present_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permanent_address"
  end

  create_table "user_referrals", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "referral_count",                                           :default => 0
    t.integer  "paid_referral_count",                                      :default => 0
    t.decimal  "referral_balance",          :precision => 18, :scale => 2, :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "registered_referral_count",                                :default => 0
  end

  create_table "user_salary_details", :force => true do |t|
    t.integer  "user_id",                           :null => false
    t.string   "work_type"
    t.integer  "status"
    t.text     "work_location"
    t.string   "work_phone",          :limit => 10
    t.date     "date_of_joining"
    t.string   "bank_account_number", :limit => 20
    t.string   "branch"
    t.string   "bank_name"
    t.string   "PAN"
    t.string   "EPS_account_number",  :limit => 25
    t.string   "PF_account_number",   :limit => 25
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date_of_leaving"
    t.string   "employee_no"
    t.string   "payment_type"
    t.string   "ifsc_code"
  end

  create_table "usernotes", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.integer  "company_id",                                            :null => false
    t.string   "username",            :limit => 32,                     :null => false
    t.string   "hashed_password",                                       :null => false
    t.string   "salt",                                                  :null => false
    t.string   "first_name",          :limit => 100,                    :null => false
    t.string   "last_name",           :limit => 100,                    :null => false
    t.string   "email",                                                 :null => false
    t.integer  "department_id"
    t.integer  "designation_id"
    t.integer  "reporting_to_id"
    t.datetime "last_login_time"
    t.boolean  "deleted",                            :default => false
    t.datetime "deleted_datetime"
    t.integer  "deleted_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "reset_password",                     :default => false
    t.integer  "branch_id"
    t.string   "prefix"
    t.string   "middle_name"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.string   "remote_ip",           :limit => 15
    t.integer  "feedback"
    t.text     "feedback_comment"
    t.integer  "login_count",                        :default => 0
  end

  create_table "variable_payhead_details", :force => true do |t|
    t.integer  "company_id",                                                 :null => false
    t.integer  "user_id",                                                    :null => false
    t.integer  "payhead_id",                                                 :null => false
    t.decimal  "amount",     :precision => 18, :scale => 2, :default => 0.0, :null => false
    t.date     "month"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendor_imports", :force => true do |t|
    t.integer  "import_file_id"
    t.string   "name"
    t.string   "opening_balance"
    t.string   "phone_number"
    t.string   "currency"
    t.string   "email"
    t.string   "website"
    t.string   "pan"
    t.string   "tan"
    t.string   "vat_tin"
    t.string   "excise_reg_no"
    t.string   "service_tax_reg_no"
    t.string   "sales_tax_no"
    t.string   "lbt_registration_number"
    t.string   "cst"
    t.string   "billing_address"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "postal_code"
    t.string   "shipping_address"
    t.integer  "created_by"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vendors", :force => true do |t|
    t.integer  "company_id",                           :null => false
    t.string   "name",                                 :null => false
    t.string   "email"
    t.string   "pan"
    t.string   "sales_tax_no"
    t.string   "tan"
    t.string   "vat_tin"
    t.string   "cst"
    t.string   "excise_reg_no"
    t.string   "service_tax_reg_no"
    t.string   "website"
    t.string   "incorporated_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.string   "lbt_registration_number"
    t.string   "primary_phone_number"
    t.integer  "currency_id"
    t.string   "gstn_id"
    t.string   "tax_reg_no"
    t.string   "payment_information"
    t.string   "secondary_phone_number"
    t.integer  "gst_category_id",         :limit => 3
  end

  create_table "voucher_settings", :force => true do |t|
    t.integer  "company_id"
    t.integer  "voucher_number_strategy"
    t.string   "prefix"
    t.string   "suffix"
    t.integer  "voucher_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "customer_notes"
    t.text     "terms_and_conditions"
  end

  create_table "voucher_titles", :force => true do |t|
    t.integer  "company_id",                      :null => false
    t.string   "voucher_type",                    :null => false
    t.string   "voucher_title"
    t.boolean  "status",        :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "vouchers", :force => true do |t|
    t.string   "voucher_number"
    t.string   "type"
    t.date     "record_date"
    t.date     "due_date"
    t.text     "bill_reference"
    t.date     "bill_date"
    t.integer  "created_by"
    t.integer  "approved_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "warehouses", :force => true do |t|
    t.integer  "company_id", :null => false
    t.integer  "manager_id"
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.string   "city"
    t.string   "pincode"
    t.integer  "created_by", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "webhook_payments", :force => true do |t|
    t.string   "payment_request_id",                                                                :null => false
    t.string   "payment_id",                                                                        :null => false
    t.string   "customer_name"
    t.string   "currency",                                                                          :null => false
    t.decimal  "amount",                            :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "fees",                              :precision => 18, :scale => 2, :default => 0.0
    t.decimal  "decimal",                           :precision => 18, :scale => 2, :default => 0.0
    t.string   "longurl",                                                                           :null => false
    t.string   "mac",                                                                               :null => false
    t.string   "status",                                                                            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remote_ip",          :limit => 100
  end

  create_table "webinars", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.date     "date"
    t.string   "city"
    t.text     "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "withdrawal_sequences", :force => true do |t|
    t.integer  "company_id",                         :null => false
    t.integer  "withdrawal_sequence", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "withdrawals", :force => true do |t|
    t.integer  "company_id",                                                          :null => false
    t.integer  "created_by",                                                          :null => false
    t.string   "voucher_number"
    t.date     "transaction_date"
    t.decimal  "amount",            :precision => 18, :scale => 2, :default => 0.0
    t.integer  "from_account_id",                                                     :null => false
    t.integer  "to_account_id",                                                       :null => false
    t.string   "description"
    t.boolean  "deleted",                                          :default => false
    t.integer  "deleted_by"
    t.datetime "deleted_datetime"
    t.string   "deleted_reason"
    t.integer  "restored_by"
    t.datetime "restored_datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "branch_id"
  end

  create_table "workstreams", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.datetime "action_time"
    t.string   "IP_address",  :limit => 100
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "action_code"
    t.integer  "branch_id"
    t.integer  "customer_id"
    t.integer  "vendor_id"
    t.integer  "project_id"
  end

  create_table "years", :force => true do |t|
    t.string "name", :null => false
  end

end
