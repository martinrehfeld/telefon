set :application, "telefon"

set :scm,        :git
set :repository, "git@github.com:martinrehfeld/telefon.git"
set :branch,     "master"

set :deploy_via, :remote_cache
set :deploy_to, "/var/rails/#{application}"

set :ssh_options, { :forward_agent => true }
set :user, "www-data"            # defaults to the currently logged in user
set :use_sudo, false             # do not use sudo

role :app, "media.local"
role :web, "media.local"
role :db,  "media.local", :primary => true

namespace :deploy do
  
  desc "Restart Mongrels, leave Apache running"
  task :restart, :roles => :app do
    sudo "/etc/init.d/mongrel_cluster restart"
  end

  desc "Cold-start Mongrels, Apache is assumed to be running"
  task :start, :roles => :app do
    sudo "/etc/init.d/mongrel_cluster start"
  end
  
  desc "Stop Mongrels, Apache is left running"
  task :stop, :roles => :app do
    sudo "/etc/init.d/mongrel_cluster stop"
  end
  
  desc "Copy local sipgate.yml to server"
  task :copy_sipgate_config do
    put(File.read('config/sipgate.yml'),"#{current_path}/config/sipgate.yml", :mode => 0600)
  end

  desc "Copy local database.production.yml to server"
  task :copy_db_config do
    put(File.read('config/database.production.yml'),"#{release_path}/config/database.yml", :mode => 0600)
  end

  after "deploy:symlink", "deploy:copy_sipgate_config" 
  after "deploy:update_code", "deploy:copy_db_config" 
end


