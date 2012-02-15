require_recipe 'postgresql9::server_install'

execute "create database user #{node[:postgresql9][:db_user]}" do
  command "createuser -dSR #{node[:postgresql9][:db_user]}"
  user "postgres"
  not_if %{ su postgres -c "psql -c 'SELECT * from pg_roles' |grep -q #{node[:postgresql9][:db_user]}" } 
end

execute "set database user #{node[:postgresql9][:db_user]} password" do
  command %{psql -d postgres -c "ALTER USER #{node[:postgresql9][:db_user]} with password '#{node[:postgresql9][:password]}a;' "}
  user "postgres"
end
