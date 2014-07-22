job_filename = "dummy_job.xml"
job_file_path = File.join(Chef::Config[:file_cache_path], job_filename)
conf = node

template job_file_path do
  source 'jenkins_job.xml.erb'
  variables({ git_url: conf[:git_url],
              build_cmd: conf[:build_cmd] })
end
