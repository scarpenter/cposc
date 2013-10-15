default_run_options[:pty] = true

set :application, "cposc"
set :scm, :git
set :branch, :master
set :repository,  "https://github.com/scarpenter/cposc.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

require "bundler/capistrano"

set :user, "sean"
set :use_sudo, false
set :deploy_to, "/var/www/#{application}"

role :web, "cposc-demo.seancarpenter.net"                          # Your HTTP server, Apache/etc
role :app, "cposc-demo.seancarpenter.net"                          # This may be the same as your `Web` server
role :db,  "cposc-demo.seancarpenter.net", :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

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

UNICORN_PID_FILE = "/var/www/#{application}/shared/pids/unicorn.pid"

def remote_process_exists?
  "[ -e #{UNICORN_PID_FILE} ] && kill -0 `cat #{UNICORN_PID_FILE}` > /dev/null 2>&1"
end

def send_signal(signal)
  "kill -s #{signal} `cat #{UNICORN_PID_FILE}`"
end

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run <<-END
      set -x;
      if #{remote_process_exists?}; then
        echo "Reloading Unicorn...";
        #{send_signal('USR2')};
      else
        echo "****Unicorn not running!!!!!";
      fi;
    END
  end
end
