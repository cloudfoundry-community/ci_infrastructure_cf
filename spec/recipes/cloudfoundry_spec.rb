require 'spec_helper'


describe 'ci_infrastructure_cf::cloudfoundry' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_ci_job']) do |n|
      n.set['ci_infrastructure_cf'][ 'jobs']['cloudfoundry']= job_attrs
    end.converge(described_recipe)
  end

  let(:job_attrs){{}}


  describe 'when creates sec_groups' do
    it 'creates cf-private udp permissions' do
      expect(chef_run).to create_sec_group('cf-private-udp').with(
        sg_name: 'cf-private',
        protocol: 'udp',
        ports: [68, 3456]
      )
    end

    it 'creates cf-private udp permissions' do
      expect(chef_run).to create_sec_group('cf-private-tcp').with(
        sg_name: 'cf-private',
        protocol: 'tcp',
        ports: (1..65535).to_a
      )
    end
    it 'creates cf-public tcp'
    it 'creates cf-public udp'
  end
  it 'creates cloudfoundry jenkins ci job' do
    expect(chef_run).to create_jenkins_ci_job('CloudFoundry')
  end
end
