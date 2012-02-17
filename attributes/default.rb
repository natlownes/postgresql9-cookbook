
default[:postgresql9][:db_user] = 'deploy'
default[:postgresql9][:password] = 'pa$$word'
default[:postgresql9][:db_path] = "/db/postgresql"

default[:postgresql9][:settings][:max_connections] = 20
