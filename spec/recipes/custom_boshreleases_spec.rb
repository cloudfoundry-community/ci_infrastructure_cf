require 'spec_helper'


describe 'ci_infrastructure_cf::custom_boshreleases' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_ci_job']) do |n|
      n.set['ci_infrastructure_cf'][ 'jobs']= jobs_attrs
    end.converge(described_recipe)
  end

  let(:jobs_attrs) do
    {
      cloudfoundry: {},
      microbosh: {},
      bosh: {},
      custom_a: {},
      custom_b: {}
    }
  end

  %w{ cloudfoundry microbosh bosh }.each do |job|
    it "should not create_jenkins_job for #{job}" do
      expect(chef_run).not_to create_jenkins_ci_job(job)
    end
  end

  %w{ custom_a custom_b }.each do |job|
    it "should create_jenkins_job for #{job}" do
      expect(chef_run).to create_jenkins_ci_job(job)
    end
  end
end
