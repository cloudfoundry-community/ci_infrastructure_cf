require 'spec_helper'

describe 'ci_infrastructure_cf::create_credentials' do
  def credentials
    [
      {name: 'credential_a' , key: 'RSA a'},
      {name: 'credential_b' , key: 'RSA b'}
    ]
  end
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['rbenv']['install_pkgs'] = %w{git-core grep}
      node.set['ci_infrastructure_cf']['credentials'] = credentials
    end.converge(described_recipe)
  end



  let(:resource) do
    chef_run.find_resource( :jenkins_private_key_credentials,
                           'infrastructure-prototypes')
  end

    [
      {name: 'credential_a' , key: 'RSA a'},
      {name: 'credential_b' , key: 'RSA b'}
    ].each do |c|
    it "creates credentials for #{c.fetch(:name)}" do
      expect(chef_run).to create_jenkins_private_key_credentials(c.fetch(:name))
      .with( private_key: c.fetch(:key ) )
    end
  end


  pending 'logs an info message' do
    expect(chef_run).to notify('log[create-credential-msg]').to(:write)
  end

  it 'defines log message resource' do
    expect(chef_run.find_resource(:log,
                                  'create-credential-msg')).to be
  end
end
