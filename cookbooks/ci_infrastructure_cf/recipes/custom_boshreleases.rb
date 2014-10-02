node.include_attribute 'ci_infrastructure_cf::cloudfoundry'

sec_group 'cf-private-udp' do
  sg_name 'cf-private'
  protocol 'udp'
  ports [68, 3456]
  action :create
end


node[:ci_infrastructure_cf][:jobs].each do |job_name, atts|
  jenkins_ci_job job_name do
    action :create
 end unless %w{ cloudfoundry microbosh bosh }.include? job_name
end




