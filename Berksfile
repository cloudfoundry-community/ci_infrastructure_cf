source "https://api.berkshelf.com"

cookbook 'jenkins'
# cookbook 'rbenv', git: 'https://github.com/fnichol/chef-rbenv.git'
cookbook 'rbenv', path: '/home/ubuntu/workspace/chef-rbenv'
cookbook 'ruby_build'
cookbook 'ci_infrastructure_cf', path: 'cookbooks/ci_infrastructure_cf'
cookbook 'hostsfile'

group :integration do
  cookbook 'jenkins_job_template', path: 'spec/fixtures/cookbooks/jenkins_job_template'
  cookbook 'replace_placeholder', path: 'spec/fixtures/cookbooks/replace_placeholder'
end
