require 'spec_helper'

describe 'ci_infrastructure_cf::hostsfile' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set[:ci_infrastructure_cf][:hosts].tap do |n|
        n['11.11.11.11'] = 'example.com'
        n['22.22.22.22'] = 'example_two.com'
      end
    end.converge(described_recipe)
  end

  ['11.11.11.11' ,'22.22.22.22'].each do |ip|
    it "sets the #{ip} in hostfile if missing" do
      expect(chef_run).to create_hostsfile_entry_if_missing(ip)
    end
  end
end
