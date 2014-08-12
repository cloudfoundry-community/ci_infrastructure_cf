include_recipe 'jenkins::master'
include_recipe 'ci_infrastructure_cf::dependencies'
include_recipe 'ci_infrastructure_cf::create_credentials'
include_recipe 'ci_infrastructure_cf::microbosh'
include_recipe 'ci_infrastructure_cf::hostsfile'
include_recipe 'ci_infrastructure_cf::bosh'
include_recipe 'ci_infrastructure_cf::cloudfoundry'

