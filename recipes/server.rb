require 'digest/md5'
require_recipe 'postgresql9::server_install'

execute "create database user #{node[:postgresql9][:db_user]}" do
  command "createuser -dSR #{node[:postgresql9][:db_user]}"
  user "postgres"
  not_if %{ su postgres -c "psql -c 'SELECT * from pg_roles' |grep -q #{node[:postgresql9][:db_user]}" } 
end


md5_password = ::Digest::MD5.hexdigest(node[:postgresql9][:password])
execute "set database user #{node[:postgresql9][:db_user]} password" do
  command %{psql -d postgres -c "ALTER USER #{node[:postgresql9][:db_user]} ENCRYPTED PASSWORD '#{md5_password}'; "}
  user "postgres"
end

template "/etc/postgresql/9.0/main/pg_hba.conf" do
  source "pg_hba.conf.erb"
end

template "/etc/postgresql/9.0/main/postgresql.conf" do
  source "postgresql.conf.erb"
end

execute "ensure postgres ownership of config files" do
  command "chown -R postgres /etc/postgresql"
  notifies :restart,     resources(:service => "postgresql"), :immediately
end

db_path = "#{node[:postgresql9][:db_path]}/data"

directory node[:postgresql9][:db_path] do
  action :create
  recursive true
end

execute "init-postgres" do                                                                                        
  command "initdb -D #{db_path} --encoding=UTF8 --locale=en_US.UTF-8"
  action :run                                                                                                   
  user 'postgres'                                                                                               
  only_if "[ ! -d #{db_path}]"                                      
end                                                                                                               
                                                                                                                  
execute "change db ownership to postgres" do
  command "chown -R postgres #{db_path}"
  notifies :restart, resources(:service => "postgresql"), :immediately
end
