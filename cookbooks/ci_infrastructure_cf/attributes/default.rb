default[:ci_infrastructure_cf][:credentials][:infrastructure_prototypes] = 'RSA PRIVATE KEY'
default[:spiff][:url]= 'https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0/spiff_linux_amd64.zip'
default[:ci_infrastructure_cf][:jobs].tap do |jobs|
  jobs[:microbosh].tap do |microbosh|
    microbosh[:provider][:name] = 'openstack|aws|etc'
    microbosh[:provider][:user] = 'admin'
    microbosh[:provider][:pass] = 'admin'
    microbosh[:provider][:tenant] = 'dev'
    microbosh[:provider][:auth_url]= 'https://example.com:5000/v2.0/tokens'
    microbosh[:address][:subnet_id]= 'SUBNET_ID'
    microbosh[:address][:ip]= 'IP'
    microbosh[:build_cmd] = '''
      rbenv local 1.9.3-p194
      echo &apos;1\n&apos; | bosh-bootstrap deploy
    '''
  end
  jobs[:bosh].tap do |bosh|
    bosh[:git_url] = 'https://github.com/cloudfoundry/bosh.git'
    bosh[:build_cmd] = '''
      rbenv local 1.9.3-p194
      echo &apos;DEPLOY BOSH&apos;
    '''
  end
end
default[:ci_infrastructure_cf][:hosts]
default[:rbenv][:user_installs] = [{ user: 'jenkins'}]
default['rbenv']['user_home_root'] = '/var/lib/'
