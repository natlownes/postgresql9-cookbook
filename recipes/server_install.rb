if (node[:platform] == 'ubuntu') && (node[:lsb][:release].to_f < 11.04)
  packages = %w(postgresql-9.0 postgresql-client-9.0 postgresql-contrib-9.0 libpq-dev libxml2 libxml2-dev libxml2-utils libxslt1.1 libxslt1-dev)

  packages.each do |pkg|
    package pkg do
      options "--force-yes"
      action :install
    end
  end
end

if node[:platform] == 'debian'
  packages = %w(postgresql-9.0 postgresql-client-9.0 postgresql-contrib-9.0)

  package "postgresql-common" do
    options "--force-yes -t lenny-backports"
    action :install
  end

  packages.each do |pkg|
    package pkg do
      options "--force-yes -t lenny-backports-sloppy"
      action :install
    end
  end
end

if node[:platform] == 'ubuntu' && (node[:lsb][:release].to_f >= 11.04)
  # will install 9.1
  packages = %w(postgresql postgresql-client postgresql-common postgresql-contrib libpq-dev)

  packages.each do |pkg|
    package pkg do
      action :install
    end
  end
end

