# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

 # Use any day of the week or :weekend, :weekday

# set the environment in development mode as it defaults to production
# set :environment, :development

#for default path related issue
env :PATH, ENV['PATH']

#this is a test task
#every 1.days, :at => "6pm" do
# runner "User.hello_user" , :output => 'log/cron.log'
#end

#task to sent weekly snapshot of dashboard
#every :sunday, :at=> "1am" do
#  runner "app/models/summary_created.rb", :output =>'log/cron.log'
#end

#task to run payroll every 30 minutes send reminder email
#every 30.minutes do
#  rake "payroll:process", :output =>'log/cron.log'
#end

every :hour do
  rake "db:backup", :output =>'log/cron.log'
end

every 1.days, :at => "12am" do
	rake "invoice:repeat", :output => 'log/cron.log'
end

every 1.days, :at => "11pm" do
  rake "financial_year:create_financial_year", :output => 'log/cron.log'
end

# every 1.days, :at => "9am" do
#   rake "daily_emails:send_mail_to_admin", :output => 'log/cron.log'
# end
# every 1.days, :at => "11pm" do
#   rake "daily_emails:send_morning_mail_to_admin", :output => 'log/cron.log'
# end
#every 1.days, :at => "11am" do
#  rake "daily_emails:send_evening_mail_to_admin", :output => 'log/cron.log'
#end
