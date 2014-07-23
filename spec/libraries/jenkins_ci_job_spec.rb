require 'spec_helper'

describe 'jenkins_ci_job::create' do
  let(:job_name){ 'Microbosh' }
  let(:chef_run) do
    ChefSpec::Runner.new(
      step_into: ['jenkins_ci_job']
    ).converge(described_recipe)
  end
  let(:filename){ "#{job_name.downcase}_job.xml" }
  let(:config_file){ File.join(Chef::Config[:file_cache_path],
                               filename) }
  let(:bosh_job_template){ 'jenkins_job.xml' }

  it 'runs the resource' do
    expect(chef_run).to create_jenkins_ci_job(job_name)
  end

  it 'creates the process template' do
    expect(chef_run).to create_template(config_file)
  end

  it 'creates jenkins job' do
    expect(chef_run).to create_jenkins_job(job_name).with(
      config: config_file)
  end

  # pending 'assigns the correct credentials to the file' do
    # expect(resource).to notify('ruby_block[assign-credential]').to(:run)
  # end
end

