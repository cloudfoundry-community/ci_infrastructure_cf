require 'spec_helper'
require_relative '../../cookbooks/ci_infrastructure_cf/libraries/stemcell_manager'

describe 'stemcell::download' do
  let(:stemcell_name) { 'bosh-openstack-kvm-ubuntu-lucid'}
  let(:stemcell_version){ 'latest'}

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['stemcell']) do |n|
      n.set['stemcell_name'] = stemcell_name
      n.set['stemcell_version'] = stemcell_version
    end.converge(described_recipe)
  end

  let(:stemcell_manager){ double.as_null_object }

  before do
    allow(CiInfrastructureCf::StemcellManager).to receive(:new).with(
       stemcell_name, stemcell_version).and_return(stemcell_manager)
  end

  it 'creates sec group' do
    expect(chef_run).to download_stemcell('dummy-download').with(
      stemcell_version: stemcell_version,
      stemcell_name: stemcell_name
    )
  end

  it 'creates the security group' do
    expect(stemcell_manager).to receive(:download)
    chef_run
  end
end

