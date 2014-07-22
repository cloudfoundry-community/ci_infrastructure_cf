replace_placeholder 'GIT_URL_PLACEHOLDER' do
  source "#{`pwd`.strip}/tmp/dummy_job.xml"
  replace_with  'git@github.com:cloudfoundry/bosh.git'
end
