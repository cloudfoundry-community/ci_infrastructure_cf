require 'spec_helper'

describe 'ci_infrastructure_cf::create_credentials' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['rbenv']['install_pkgs'] = %w{git-core grep}
    end.converge(described_recipe)
  end
  let(:resource) do
    chef_run.find_resource( :jenkins_private_key_credentials,
                           'infrastructure-prototypes')
  end

  it 'creates credentials for instrastructure prototype repo' do
    expect(chef_run).to create_jenkins_private_key_credentials('infrastructure-prototypes')
  end

  it 'asigns infrastructure prototypes key' do
    expect(resource.private_key).to include('RSA PRIVATE KEY')
  end

  it 'logs an info message' do
    expect(resource).to notify('log[create-credential-msg]').to(:write)
  end

  it 'defines enable-cli-msg resource' do
    expect(chef_run.find_resource(:log,
                                  'create-credential-msg')).to be
  end
end
