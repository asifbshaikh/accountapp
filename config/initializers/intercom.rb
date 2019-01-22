if Rails.env.production?
IntercomRails.config do |config|
  # == Intercom app_id
  #
  config.app_id = ENV["INTERCOM_APP_ID"] || "402c2c9d003ab5c965babf93ec504bed456a7bc4"
  # == Intercom secret key
  # This is required to enable secure mode, you can find it on your Intercom
  # "security" configuration page.
  #
  config.api_secret = "SGeELER14acbzgAJkE9MtyEwIKZCXg_mzSm4n5J8"
  # == Intercom API Key
  # This is required for some Intercom rake tasks like importing your users;
  # you can generate one at https://www.intercom.io/apps/api_keys.
  #
   config.api_key = "065d35a9ccd7d2d3d8ebb51d3279af9e5b5ac0ef"


  # == Curent user name
  # The method/variable that contains the logged in user in your controllers.
  # If it is `current_user` or `@user`, then you can ignore this
  #
   config.user.current = Proc.new { current_user }

  # == User model class
  # The class which defines your user model
  #
   config.user.model = Proc.new { User }

  # == User Custom Data
  # A hash of additional data you wish to send about your users.
  # You can provide either a method name which will be sent to the current
  # user object, or a Proc which will be passed the current user.
  #
   config.user.custom_data = {
        # :name => Proc.new{|current_user| current_user.full_name},
        # :username => Proc.new{|current_user| current_user.username},
        # :email => Proc.new{|current_user| current_user.email},
        # :company => Proc.new{|current_user| current_user.company.name},
        # :plan => Proc.new{|current_user| current_user.company.plan.display_name},
     }

  # == User -> Company association
  # A Proc that given a user returns an array of companies
  # that the user belongs to.
  #
  # config.user.company_association = Proc.new { |user| user.companies.to_a }
  # config.user.company_association = Proc.new { |user| [user.company] }

  # == Current company name
  # The method/variable that contains the current company for the current user,
  # in your controllers. 'Companies' are generic groupings of users, so this
  # could be a company, app or group.
  #
   config.company.current = Proc.new { company }


  # == Company Custom Data
  # A hash of additional data you wish to send about a company.
  # This works the same as User custom data above.
  #
   config.company.custom_data = {
      :number_of_messages => Proc.new { |company| @company.messages.count },
      :total_invoices => Proc.new {|company| @company.invoices.count},
      :total_projects => Proc.new {|company| @company.projects.count},
      :total_products => Proc.new {|company| @company.products.count},
      :total_expenses => Proc.new {|company| @company.expenses.count},
      :total_tasks => Proc.new {|company| @company.tasks.count},
      :total_employees => Proc.new {|company| @company.users.count},
      :in_app_msg => Proc.new {|company| @company.messages.count},
      :value =>  Proc.new {|company| @company.total_values},
      :days_until_expiry => Proc.new {|company| @company.days_left},
   }

  # == Company Plan name
  # This is the name of the plan a company is currently paying (or not paying) for.
  # e.g. Messaging, Free, Pro, etc.
  #
  config.company.plan = Proc.new { @company.plan.display_name }


  # == Company Monthly Spend
  # This is the amount the company spends each month on your app. If your company
  # has a plan, it will set the 'total value' of that plan appropriately.
  #
   config.company.monthly_spend = Proc.new { |company| @company.plan.price }
  # config.company.monthly_spend = Proc.new { |@company| (@company.plan.price - @company.subscription.discount) }

  # == Inbox Style
  # This enables the Intercom inbox which allows your users to read their
  # past conversations with your app, as well as start new ones. It is
  # disabled by default.
  #   * :default shows a small tab with a question mark icon on it
  #   * :custom attaches the inbox open event to an anchor with an
  #             id of #Intercom.
  #
   # config.inbox.style = :default
    config.inbox.style = :custom

  # == Inbox Counter
  # If you're using the custom inbox style, you can request that Intercom
  # insert an `em` element into your anchor with the count of unread messages
  #
   config.inbox.counter = true

end
 end
