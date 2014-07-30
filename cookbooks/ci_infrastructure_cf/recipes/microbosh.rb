job_name = 'Microbosh'
conf = node[:ci_infrastructure_cf][:jobs][job_name.downcase]

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

jenkins_ci_job(job_name)

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
end
