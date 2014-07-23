require 'spec_helper'

describe 'jenkins_job_template::create' do
let(:job_filename){ "dummy_job.xml" }
let(:job_file_path){ File.join(Chef::Config[:file_cache_path],
                               job_filename) }
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set[:git_url] = git_url
      node.set[:build_cmd] = build_cmd
    end.converge(described_recipe)
  end

  describe 'when params are providedprovided' do
    let(:git_url){ 'https://github.com/something/something.git' }
    let(:build_cmd){ "echo 'BUILD!!!'" }

    it 'should include scm node' do
      expect(chef_run).to render_file(job_file_path)
        .with_content('</scm>')
    end

    it 'should include the git url' do
      expect(chef_run).to render_file(job_file_path)
        .with_content(git_url)
    end

    it 'should include the build_cmd'
  end

  describe 'when params are empty' do
    let(:git_url){ '' }
    let(:build_cmd){ '' }

    it 'should not include scm node' do
      expect(chef_run).not_to render_file(job_file_path)
        .with_content('</scm>')
    end

    it 'should not include the git url' do
      expect(chef_run).not_to render_file(job_file_path)
        .with_content('something.git')
    end

    it 'should use the default build_cmd'
  end
  describe 'when params are nil' do
    let(:git_url){ nil }
    let(:build_cmd){ nil }

    it 'should not include scm node' do
      expect(chef_run).not_to render_file(job_file_path)
        .with_content('</scm>')
    end

    it 'should not include the git url' do
      expect(chef_run).not_to render_file(job_file_path)
        .with_content('something.git')
    end
  end
end
