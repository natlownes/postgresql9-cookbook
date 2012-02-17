require 'digest/md5'
require_recipe 'postgresql9::server_install'

postgres_version = "9.0"
binaries_path = "/usr/lib/postgresql/#{postgres_version}/bin"
db_path = "#{node[:postgresql9][:db_path]}/data"

md5_password = ::Digest::MD5.hexdigest(node[:postgresql9][:password])

service 'postgresql' do
  action :stop
end

template "/etc/postgresql/9.0/main/pg_hba.conf" do
  source "pg_hba.conf.erb"
end

template "/etc/postgresql/9.0/main/postgresql.conf" do
  source "postgresql.conf.erb"
  variables(
    :db_path => db_path
  )
end

execute "halt-postgres-for-db-path-switch" do
  command "killall postgres"
  # stop postgres if we've installed/started it
  # since we'll be changing the data directory 
  # if it doesn't exist
  action :run
  only_if { (`pgrep postgres`.length != 0) && !File.directory?(db_path) }
end

execute "set-database-user-password" do
  command %{psql -d postgres -c "ALTER USER #{node[:postgresql9][:db_user]} ENCRYPTED PASSWORD '#{md5_password}'; "}
  user "postgres"

  action :nothing
end

execute "create-database-user" do
  command "createuser -dSR #{node[:postgresql9][:db_user]}"
  user "postgres"
  not_if %{ su postgres -c "psql -c 'SELECT * from pg_roles' |grep -q #{node[:postgresql9][:db_user]}" } 

  action :nothing

  notifies :run, resources(:execute => 'set-database-user-password'), :immediately
end

execute "change-db-ownership-to-postgres" do
  command "chown -R postgres #{db_path}"
  action :nothing

  notifies :run, resources(:execute => 'create-database-user'), :delayed
  notifies :restart, resources(:service => "postgresql"), :delayed
end
                                                                                                                  
execute "init-postgres" do                                                                                        
  command "#{binaries_path}/initdb -D #{db_path} --encoding=UTF8 --locale=en_US.UTF-8"
  action :nothing                                                                                                   
  user 'postgres'                                                                                               
  only_if { !File.directory?(db_path) }

  notifies :run, resources(:execute => "change-db-ownership-to-postgres"), :immediately
end                                                                                                               

directory node[:postgresql9][:db_path] do
  action :create
  recursive true
  owner 'postgres'
  group 'postgres'
  notifies :run, resources(:execute => "init-postgres"), :immediately
end

execute "ensure postgres ownership of config files" do
  command "chown -R postgres /etc/postgresql"
  notifies :restart,     resources(:service => "postgresql")
end

