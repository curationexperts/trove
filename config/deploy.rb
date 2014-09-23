# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'tdil'
set :scm, :git
set :repo_url, 'https://github.com/curationexperts/tufts-image-library.git'
set :branch, 'master'
set :deploy_to, '/opt/tdil'
set :log_level, :debug
set :keep_releases, 5

# Default value for :linked_files is []
set :linked_files, %w{config/application.yml config/database.yml config/feature_data.yml config/java.yml config/fedora.yml config/secrets.yml config/solr.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin tmp/pids tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do

before :publishing, :java

  desc 'Compile Java'
  task :java do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
    execute "cd #{release_path}/java && ant"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
