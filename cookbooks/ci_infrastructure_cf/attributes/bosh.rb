
node.include_attribute 'ci_infrastructure_cf::microbosh'

microbosh = JobConf.new('microbosh', node)
bosh      = JobConf.new('bosh', node)


default[:ci_infrastructure_cf][:jobs][:bosh].tap do |j|
  j[:scm]= [
      { url: 'https://github.com/cloudfoundry/bosh.git',
        credential: 'delete_me'
  }]

  j[:build_cmd]=  """
    rbenv local 1.9.3-p194
    bosh -n target #{microbosh.address.ip}
    bosh login admin admin
    bosh -n upload release $(pwd)/release/releases/bosh-93.yml --skip-if-exists
    ~/templates/bosh/generate_manifest ~/stubs/bosh.yml
    ~/bin/set_director_uuid deployment.yml
    bosh deployer provision stemcells
    bosh deployment deployment.yml
    bosh -n deploy
 """
end
