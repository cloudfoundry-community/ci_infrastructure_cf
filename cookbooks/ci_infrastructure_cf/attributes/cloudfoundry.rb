node.include_attribute 'ci_infrastructure_cf::microbosh'
node.include_attribute 'ci_infrastructure_cf::bosh'

microbosh    = JobConf.new('microbosh', node)
bosh         = JobConf.new('bosh', node)
cloudfoundry = JobConf.new('cloudfoundry', node)

default[:ci_infrastructure_cf][:jobs][:cloudfoundry].tap do |j|
  j[:scm]= [
      { url: 'https://github.com/cloudfoundry/cf-release.git' }
  ]
  j[:spiff_stub]=
    cloudfoundry.spiff_stub.to_hash.deep_merge( {
    meta:{
      'bosh-network'=>{
        cidr: bosh.spiff_stub.meta.networks.manual.range
      }
    },
    networks:
      {floating:{
          cloud_properties: {
            net_id: microbosh.address.subnet_id,
          }
        },
      'cf-dynamic' => {
        cloud_properties: {
          net_id: microbosh.address.subnet_id,
          range: bosh.spiff_stub.meta.networks.manual.range,
        }
      }
    },
  })
  j[:build_cmd]=  """
    rbenv local 1.9.3-p194
    git checkout v175
    bosh -n target #{bosh.spiff_stub.meta.networks.manual.static.first.split('-').first.strip}
    bosh login admin admin
    bosh -n upload release $(pwd)/releases/cf-175.yml --skip-if-exists
    ./generate_deployment_manifest openstack ~/stubs/cloudfoundry.stub.yml > deployment.yml
    ~/bin/set_director_uuid deployment.yml
    bosh -n upload stemcell ~/stemcells/bosh-stemcell-latest-openstack-kvm-ubuntu-lucid-go_agent.tgz --skip-if-exists

    bosh deployment deployment.yml
    bosh -n deploy
 """
end
