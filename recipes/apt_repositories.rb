require_recipe 'apt'

if (node[:platform] == 'ubuntu') && (node[:lsb][:release].to_f < 11.04)
  apt_repository 'ppa-pitti-postgresql' do
    uri 'http://ppa.launchpad.net/pitti/postgresql/ubuntu'
    distribution node['lsb']['codename']
    components ['main']
    action :add
    notifies :run, resources(:execute => "apt-get update"), :immediately
  end
end

if node[:platform] == 'debian'
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
end

if node[:platform] == 'ubuntu' && (node[:lsb][:release].to_f >= 11.04)
end
