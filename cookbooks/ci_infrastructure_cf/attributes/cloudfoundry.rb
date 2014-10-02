node.include_attribute 'ci_infrastructure_cf::microbosh'
node.include_attribute 'ci_infrastructure_cf::bosh'

microbosh    = JobConf.new('microbosh', node)
bosh         = JobConf.new('bosh', node)
cloudfoundry = JobConf.new('cloudfoundry', node)

default[:ci_infrastructure_cf][:jobs][:cloudfoundry].tap do |j|
  j[:scm]= [
      { url: 'https://github.com/cloudfoundry/cf-release.git' }
  ]
  j[:build_cmd]=  """
    rbenv local 1.9.3-p194
    git checkout v175
    bosh deployer target bosh ~/stubs/bosh.yml
    bosh login admin admin
    bosh -n upload release $(pwd)/releases/cf-175.yml --skip-if-exists
    ./generate_deployment_manifest openstack ~/stubs/cloudfoundry.yml > deployment.yml
    ~/bin/set_director_uuid deployment.yml
    bosh deployer provision stemcells
    bosh deployment deployment.yml
    bosh -n deploy
 """
end
