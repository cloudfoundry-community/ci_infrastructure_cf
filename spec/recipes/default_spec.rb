require 'spec_helper'

describe 'ci_infrastructure_cf::default' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['rbenv']['install_pkgs'] = %w{git-core grep}
    end.converge(described_recipe)
  end

  %w{microbosh bosh cloudfoundry dependencies hostsfile create_credentials}.each do |recipe|
    it "includes #{recipe}" do
      expect(chef_run).to include_recipe( "ci_infrastructure_cf::#{recipe}")
    end
  end
end
