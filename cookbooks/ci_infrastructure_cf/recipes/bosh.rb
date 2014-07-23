%w{bosh_cli}.each do |gem|
  rbenv_gem gem do
    rbenv_version '1.9.3-p194'
    user 'jenkins'
  end
end

jenkins_ci_job('Bosh')


