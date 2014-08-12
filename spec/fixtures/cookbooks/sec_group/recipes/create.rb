sec_group node['sec_group_name'] do
  action :create
  protocol node['protocol']
  ports node['ports']
end
