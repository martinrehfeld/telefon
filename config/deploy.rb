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

end