
execute "create database user #{node[:postgresql9][:db_user]}" do
  command "createuser -d #{node[:postgresql9][:db_user]}"
  user "postgres"
end

execute "set database user #{node[:postgresql9][:db_user]} password" do
  command %{psql -d postgres -c "ALTER USER #{node[:postgresql9][:db_user]} with password '#{node[:postgresql9][:password]}a;' "}
  user "postgres"
end
