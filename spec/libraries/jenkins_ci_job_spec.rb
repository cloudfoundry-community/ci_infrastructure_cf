require 'spec_helper'

describe 'jenkins_ci_job::create' do
  let(:git_urls){ nil }
  let(:build_cmd){ nil }
  let(:job_name){ 'Microbosh' }
  let(:filename){ "#{job_name.downcase}_job.xml" }
  let(:job_file_path){ File.join(Chef::Config[:file_cache_path],
                               filename) }
  let(:bosh_job_template){ 'jenkins_job.xml' }
  let(:chef_run) do
    ChefSpec::Runner.new(
      step_into: ['jenkins_ci_job']
    ) do |node|
      node.set[:ci_infrastructure_cf][:jobs][job_name.downcase].tap do |j|
        j[:git_urls] = git_urls
        j[:build_cmd] = build_cmd
      end
    end.converge(described_recipe)
  end

  it 'runs the resource' do
    expect(chef_run).to create_jenkins_ci_job(job_name)
  end


  it 'creates jenkins job' do
    expect(chef_run).to create_jenkins_job(job_name).with(
      config: job_file_path)
  end

  describe 'template creation' do
    it 'creates the template' do
      expect(chef_run).to create_template(job_file_path)
    end

    describe 'when git urls are provided' do
      let(:git_urls) do
        [
          'https://github.com/something/something.git',
          'https://github.com/something/something2.git'
        ]
      end

      it 'should includes all the git urls' do
        git_urls.each do |url|
          expect(chef_run).to render_file(job_file_path)
          .with_content(url)
        end
      end
    end

    describe 'when git urls are empty' do
      let(:git_urls){ [] }
      let(:build_cmd){ '' }

      it 'should include NullSCM node' do
        expect(chef_run).to render_file(job_file_path)
          .with_content('hudson.scm.NullSCM')
      end

      it 'should not include any scm repo' do
        expect(chef_run).not_to render_file(job_file_path)
        .with_content('hudson.plugins.git.GitSCM')
      end
    end

    describe 'when params are nil' do
      let(:git_urls){ nil }
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

  # pending 'assigns the correct credentials to the file' do
  # expect(resource).to notify('ruby_block[assign-credential]').to(:run)
  # end
end

