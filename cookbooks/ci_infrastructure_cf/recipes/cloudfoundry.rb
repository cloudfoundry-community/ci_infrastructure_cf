node.include_attribute 'ci_infrastructure_cf::cloudfoundry'

jenkins_ci_job 'CloudFoundry' do
  action :create
end
