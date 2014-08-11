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

      cf1: {
        subnets: {
          default_unused: {
            range: bosh.spiff_stub.meta.networks.manual.range,
            cloud_properties: {
              net_id: microbosh.address.subnet_id
            }
          }
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
end
