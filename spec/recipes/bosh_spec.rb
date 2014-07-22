require 'spec_helper'

describe 'ci_infrastructure_cf::bosh' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  describe 'when creating xml file' do
    let(:filename){ 'bosh_job.xml' }
    let(:config_file){ File.join(Chef::Config[:file_cache_path],
                                 filename) }
    let(:bosh_job_template){ 'jenkins_job.xml' }

    it 'creates the file' do
      expect(chef_run).to create_template(config_file)
    end
  end

  %w{bosh_cli}.each do |gem|
    it "installs #{gem}" do
      expect(chef_run).to install_rbenv_gem(gem)
    end
  end

  it 'creates bosh task' do
    expect_any_instance_of(Chef::Recipe).to receive(:jenkins_job).with('Bosh')
    chef_run
  end
end
