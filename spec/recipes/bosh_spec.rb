require 'spec_helper'

describe 'ci_infrastructure_cf::bosh' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_ci_job']) do |n|
      n.set['ci_infrastructure_cf'][ 'jobs']['bosh']= job_attrs
    end.converge(described_recipe)
  end

  let(:job_attrs){{}}


  %w{bosh_cli}.each do |gem|
    it "installs #{gem}" do
      expect(chef_run).to install_rbenv_gem(gem)
    end
  end

  it 'creates bosh jenkins ci job' do
    expect(chef_run).to create_jenkins_ci_job('Bosh')
  end

  describe 'when spiff_stub is provided via attributes' do
    let(:job_attrs) do
      {spiff_stub: {
        meta: {
          networks: {
            manual: {
              static: [ '10.10.10.10 - 11.11.11.11' ],
              range: '10.0.0.0/8',
              gateway: '10.0.0.1'
            }
          }
        }
      }}
    end

    it 'merges stub provided via vagrantfile' do
      resource = chef_run.find_resource(:file, '/var/lib/jenkins/stubs/bosh.stub.yml')
      @actual_content = ChefSpec::Renderer.new(chef_run, resource).content
      @expected_content = File.read('spec/assets/bosh.stub.yml')

      actual = YAML.load(@actual_content).sort_by_key(true).to_a
      expected = YAML.load(@expected_content).sort_by_key(true).to_a

      expect(expected).to eq(actual)
    end
  end
end
