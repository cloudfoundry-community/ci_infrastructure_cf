require 'spec_helper'

describe 'replace_placeholder::run' do
  # let(:chef_run) do
    # ChefSpec::Runner.new(
      # step_into: ['replace_placeholder']
    # ).converge(described_recipe)
  # end

  # let(:created_xml) do
    # "#{`pwd`.strip}/tmp/dummy_job.xml"
  # end
  # let(:cookbook_path) { 'spec/fixtures/cookbooks/replace_placeholder'}
  # before do
     # `cp -f #{cookbook_path}/files/default/job_template.xml #{created_xml}`
  # end

  # it 'assigns the git url to the file' do
    # expect(chef_run).to run_replace_placeholder('GIT_URL_PLACEHOLDER')
      # .with(source: created_xml,
            # replace_with: 'git@github.com:cloudfoundry/bosh.git')
  # end

  # pending 'changes placeholder value' do
    # expect do
      # chef_run
    # end.to change{ File.read(created_xml).include?('bosh.git') }
  # end
end
