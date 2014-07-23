require 'spec_helper'

describe 'ci_infrastructure_cf::bosh' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }


  %w{bosh_cli}.each do |gem|
    it "installs #{gem}" do
      expect(chef_run).to install_rbenv_gem(gem)
    end
  end

  it 'creates bosh jenkins ci job' do
    expect(chef_run).to create_jenkins_ci_job('Bosh')
  end
end
