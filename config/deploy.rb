require 'bundler/capistrano'
#---
# Excerpted from "Agile Web Development with Rails, 4rd Ed.",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/rails4 for more book information.
#---
# be sure to change these
set :user, 'ubuntu'
set :domain, 'profitnext.com'
set :application, 'profitnext'
set :app_folder, 'rails-apps'
set :repository, "#{user}@#{domain}:git/#{application}.git"
set :scm, :git


# file paths
set :deploy_to, "/home/#{user}/#{app_folder}/#{application}"

ssh_options[:keys] = ["~/.ssh/profitnext_development.pem"]
# distribute your applications across servers (the instructions below put them
# all on the same server, defined above as 'domain', adjust as necessary)
role :app, domain
role :web, domain
role :db, domain, :primary => true
set :branch, "master"
set :scm_verbose, true
set :use_sudo, false
set :ssh_options, { :forward_agent => true }

# you might need to set this if you aren't seeing password prompts
  default_run_options[:pty] = true
set :default_environment, {
  'PATH' => "/home/ubuntu/.rvm/gems/ruby-1.9.3-p551/bin:/home/ubuntu/.rvm/gems/ruby-1.9.3-p551@global/bin:/home/ubuntu/.rvm/rubies/ruby-1.9.3-p551/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/home/ubuntu/.rvm/bin:/home/ubuntu/.rvm/bin",
  'RUBY_VERSION' => 'ruby-1.9.3-p551',
  'GEM_HOME'     => '/home/ubuntu/.rvm/gems/ruby-1.9.3-p551',
  'GEM_PATH'     => '/home/ubuntu/.rvm/gems/ruby-1.9.3-p551:/home/ubuntu/.rvm/gems/ruby-1.9.3-p551@global'
}

#before "deploy:update", "deploy:terminate_if_running"
#after "deploy:update", "deploy:start_god"

before "deploy:update", 'deploy:sidekiqquiet'
after "deploy:update", 'deploy:sidekiqrestart'
#after 'deploy:published', 'deploy:sidekiqrestart'
# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"



# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end


#the below code is for scheduling CRON jobs
after "deploy:create_symlink", "deploy:update_crontab"
namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
    #run "ln -s #{shared_path}/uploaded_data #{release_path}/public/uploaded_data"
    run "ln -s #{shared_path}/data/data-backup #{release_path}/db/bak"
  end
  #this is for stopping and restarting resque workers using GOD
  def god_is_running
    !capture("#{god_command} status >/dev/null 2>/dev/null || echo 'not running'").start_with?('not running')
  end

  def god_command
    "cd #{current_path}; bundle exec god"
  end

  desc "Stop god"
  task :terminate_if_running do
    if god_is_running
      run "#{god_command} terminate"
    end
  end

  # desc "Start god"
  # task :start_god do
  #   config_file = "#{current_path}/config/resque.god"
  #   environment = { :RAILS_ENV => rails_env, :RAILS_ROOT => current_path }
  #   run "#{god_command} -c #{config_file}", :env => environment
  # end

  task :sidekiqquiet do
    # Horrible hack to get PID without having to use terrible PID files
    puts capture("kill -USR1 $(sudo initctl status workers | grep /running | awk '{print $NF}') || :")
  end
  task :sidekiqrestart do
    run "sudo initctl restart workers"
  end

end


# As Capistrano executes in a non-interactive mode and therefore doesn't cause
# any of your shell profile scripts to be run, the following might be needed
# if (for example) you have locally installed gems or applications.  Note:
# this needs to contain the full values for the variables set, not simply
# the deltas.
# default_environment['PATH']='<your paths>:/usr/local/bin:/usr/bin:/bin'
# default_environment['GEM_PATH']='<your paths>:/usr/lib/ruby/gems/1.8'

# miscellaneous options
# set :deploy_via, :remote_cache
# set :scm, 'git'
# set :branch, 'master'
# set :scm_verbose, true
# set :ssh_options, { :forward_agent => true }
# set :use_sudo, false


# namespace :deploy do
#   desc "cause Passenger to initiate a restart"
#   task :restart do
#     run "touch #{current_path}/tmp/restart.txt"
#   end

#   desc "reload the database with seed data"
#   task :seed do
#     run "cd #{current_path};bundle exec rake db:seed RAILS_ENV=production" #change added
#   end
# end

# after "deploy:update_code", :bundle_install
# desc "install the necessary prerequisites"
# task :bundle_install, :roles => :app do
#   run "cd #{release_path} && bundle install --deployment"
# end

# after "deploy:create_symlink", "deploy:update_crontab"
# namespace :deploy do
#   desc "Update the crontab file"
#   task :update_crontab, :roles => :app do
#     run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
#     run "ln -s #{shared_path}/uploaded_data #{release_path}/public/uploaded_data"
#   end
# end
