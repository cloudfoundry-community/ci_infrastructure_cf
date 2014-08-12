node.include_attribute 'ci_infrastructure_cf::microbosh'

microbosh = JobConf.new('microbosh', node)
bosh      = JobConf.new('bosh', node)

default[:ci_infrastructure_cf][:jobs][:bosh].tap do |j|
  j[:scm]= [
      { url: 'https://github.com/cloudfoundry/bosh.git',
        credential: 'delete_me'
  }]
  j[:spiff_stub]=
    bosh.spiff_stub.to_hash.deep_merge( {
    properties: {
      openstack: {
        auth_url: microbosh.provider.auth_url.gsub('/tokens',''),
        username: microbosh.provider.user,
        api_key: microbosh.provider.pass,
        tenant: microbosh.provider.tenant,
      }
    },
    meta: {
      recursor: microbosh.address.ip,
      networks: {
        cloud_properties: {
          net_id: microbosh.address.subnet_id
        },
        manual:{
          static: ['1.1.1.1 - 2.2.2.2'],
          range: 'BOSH_RANGE'
        }
      }
    }
  })

  j[:build_cmd]=  """
    rbenv local 1.9.3-p194
    bosh -n target #{microbosh.address.ip}
    bosh login admin admin
    bosh -n upload release $(pwd)/release/releases/bosh-93.yml --skip-if-exists
    ~/templates/bosh/generate_manifest ~/stubs/bosh.stub.yml
    ~/bin/set_director_uuid deployment.yml
    ~/bin/upload_stemcell

    bosh deployment deployment.yml
    bosh -n deploy
 """
end
