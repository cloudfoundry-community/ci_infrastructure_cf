require 'spec_helper'
require_relative '../../cookbooks/ci_infrastructure_cf/libraries/sec_group'

describe 'sec_group::create' do
  let(:sec_group_name){ 'ssh' }
  let(:protocol){ 'tcp' }
  let(:ports){ [22] }

  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['sec_group']) do |n|
      n.set['sec_group_name'] = sec_group_name
      n.set['protocol'] = protocol
      n.set['ports'] = ports
    end.converge(described_recipe)
  end

  let(:provider){ double.as_null_object }

  before do
    allow(CiInfrastructureCf::Provider).to receive(:new).and_return(provider)
  end

  it 'creates sec group' do
    expect(chef_run).to create_sec_group(sec_group_name).with(
       protocol: protocol, ports: ports )
  end

  it 'creates the security group' do
    expect(provider).to receive(:create_security_group)
        .with('ssh', 'Automated sg generated by ci_infrastructure_cf',
                {  protocol: 'tcp', ports: [22]})
    chef_run
  end
end

