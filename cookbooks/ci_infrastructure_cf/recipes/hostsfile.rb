node[:ci_infrastructure_cf][:hosts].each_pair do |ip, host|
  hostsfile_entry ip do
    hostname host
    action :create_if_missing
  end
end
