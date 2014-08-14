node.include_attribute 'ci_infrastructure_cf::cloudfoundry'

sec_group 'cf-private-udp' do
  sg_name 'cf-private'
  protocol 'udp'
  ports [68, 3456]
  action :create
end

sec_group 'cf-private-tcp' do
  sg_name 'cf-private'
  protocol 'tcp'
  ports (1..65535).to_a
  action :create
end

jenkins_ci_job 'CloudFoundry' do
  action :create
end
