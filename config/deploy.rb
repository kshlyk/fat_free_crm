1# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'fat_free_crm'
set :repo_url, 'git@github.com:kshlyk/fat_free_crm.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml config/settings.yml config/secrets.yml config/unicorn.rb)

# Default value for linked_dirs is []
 set :linked_dirs, %w{config/environments public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rvm_ruby_version, '2.2.0'

namespace :deploy do
  after :publishing, :restart
  before :restart, :stop

  desc 'Start application'
  task :start do
    on roles(:app) do
      execute "cd #{current_path} && MAGICK_THREAD_LIMIT=1 RAILS_ENV=#{fetch(:rails_env)} rvm #{fetch(:rvm_ruby_version)} do bundle exec unicorn_rails -Dc #{shared_path}/config/unicorn.rb -E #{fetch(:rails_env)}", raise_on_non_zero_exit: false
    end
  end

  desc 'Stop application'
  task :stop do
    on roles(:app) do
      execute "kill -QUIT `cat #{shared_path}/pids/unicorn.pid` && sleep 3", raise_on_non_zero_exit: false
    end
  end

  desc 'Restart Application'
  task :restart do
    on roles(:app) do
    end
  end

  after :restart, :start  

  after :start, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
