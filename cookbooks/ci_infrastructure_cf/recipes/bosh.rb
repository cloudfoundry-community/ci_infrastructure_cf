job_name = 'bosh'
conf = node[:ci_infrastructure_cf][:jobs][job_name]
job_filename = "#{job_name}_job.xml"
job_file_path = File.join(Chef::Config[:file_cache_path], job_filename)


%w{bosh_cli}.each do |gem|
  rbenv_gem gem do
    rbenv_version '1.9.3-p194'
    user 'jenkins'
  end
end


template job_file_path do
  source 'jenkins_job.xml.erb'
  variables({ git_url: conf[:git_url],
              build_cmd: conf[:build_cmd] })
end

jenkins_job "Bosh" do
  action :create
  config job_file_path
end
