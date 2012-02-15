require_recipe 'apt'

if platform[:ubuntu] && (node[:lsb][:release].to_f < 11.04)
  apt_repository 'ppa-pitti-postgresql' do
    uri 'http://ppa.launchpad.net/pitti/postgresql/ubuntu'
    distribution node['lsb']['codename']
    components ['main']
    action :add
    notifies :run, resources(:execute => "apt-get update"), :immediately
  end

  packages = %(postgresql-9.0 libpq-dev libxml2 libxml2-dev libxml2-utils libxslt1.1 libxslt1-dev)
end

if platform[:debian]
  apt_repository 'lenny-backports' do
    uri 'http://backports.debian.org/debian-backports'
    distribution 'lenny-backports'
    components ['main']
    action :add
    notifies :run, resources(:execute => "apt-get update"), :immediately
  end

  apt_repository 'lenny-backports-sloppy' do
    uri 'http://backports.debian.org/debian-backports'
    distribution 'lenny-backports-sloppy'
    components ['main']
    action :add
    notifies :run, resources(:execute => "apt-get update"), :immediately
  end

  packages = %(postgresql-9.0 postgresql-client-9.0 postgresql-contrib-9.0)

  package "postgresql-common" do
    options "-t lenny-backports"
    action :install
  end

  packages.each do |pkg|
    package pkg do
      options "-t lenny-backports-sloppy"
      action :install
    end
  end
end

if platform[:ubuntu] && (node[:lsb][:release].to_f > 11.04)
  packages = %(postgresql libpq-dev)

  packages.each do |pkg|
    package pkg do
      action :install
    end
  end
end
