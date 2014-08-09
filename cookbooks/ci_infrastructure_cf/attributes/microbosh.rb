default[:ci_infrastructure_cf][:jobs][:microbosh].tap do |j|
    j[:provider][:name] = 'openstack|aws|etc'
    j[:provider][:user] = 'admin'
    j[:provider][:pass] = 'admin'
    j[:provider][:tenant] = 'dev'
    j[:provider][:auth_url]= 'https://example.com:5000/v2.0/tokens'
    j[:address][:subnet_id]= 'SUBNET_ID'
    j[:address][:ip]= 'IP'
    j[:build_cmd] = """
      rbenv local 1.9.3-p194
      echo '1\n' | bosh-bootstrap deploy
    """
end
