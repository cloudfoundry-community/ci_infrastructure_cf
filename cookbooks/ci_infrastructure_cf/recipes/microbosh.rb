job_name = 'microbosh'
conf = node[:ci_infrastructure_cf][:jobs][job_name]
job_filename = "#{job_name}_job.xml"
job_file_path = File.join(Chef::Config[:file_cache_path], job_filename)

%w{libmysqlclient-dev libpq-dev}.each do |pkg|
  package pkg
end

%w{fog bundler bosh-bootstrap}.each do |gem|
  rbenv_gem gem do
    rbenv_version '1.9.3-p194'
    user 'jenkins'
  end
end

execute "chown-rbenv-dir" do
  user "root"
  command "chown -R jenkins:jenkins /var/lib/jenkins/.rbenv"
end

template job_file_path do
  source 'jenkins_job.xml.erb'
  variables({ git_url: conf[:git_url],
              build_cmd: conf[:build_cmd] })
end

jenkins_job "Microbosh" do
  action :create
  config job_file_path
end

settings_dir = '/var/lib/jenkins/.microbosh'
directory(settings_dir) do
  owner 'jenkins'
  group 'jenkins'
end

template 'microbosh-settings' do
  path "#{settings_dir}/settings.yml"
  source 'microbosh_settings.yml.erb'
  owner 'jenkins'
  group 'jenkins'
  mode 00640
  variables ({
    provider_name: conf[:provider][:name],
    os_auth_name: conf[:provider][:user],
    os_auth_pass: conf[:provider][:pass],
    os_tenant: conf[:provider][:tenant],
    os_auth_url: conf[:provider][:auth_url],
    address_subnet_id: conf[:address][:subnet_id],
    address_ip: conf[:address][:ip],
  })
end
