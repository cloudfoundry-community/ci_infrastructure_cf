require 'spec_helper'

describe 'jenkins_ci_job::create' do
  let(:scm){ nil }
  let(:build_cmd){ nil }
  let(:job_name){ 'Dummy' }
  let(:filename){ "#{job_name.downcase}_job.xml" }
  let(:job_file_path){ File.join(Chef::Config[:file_cache_path],
                               filename) }
  let(:bosh_job_template){ 'jenkins_job.xml' }
  let(:chef_run) do
    ChefSpec::Runner.new(
      step_into: ['jenkins_ci_job']
    ) do |node|
      node.set[:ci_infrastructure_cf][:jobs][job_name.downcase].tap do |j|
        j[:scm] = scm
        j[:build_cmd] = build_cmd
      end
    end.converge(described_recipe)
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
      let(:scm) do
        [
          {url: 'https://github.com/something/something.git',
             credential: 'something'},
          {url: 'https://github.com/something/something2.git',
             credential: 'something2'}
        ]
      end


      it 'should includes all the git urls' do
        scm.each do |repo|
          expect(chef_run).to render_file(job_file_path)
            .with_content(repo.fetch(:url))
        end
      end

      it 'adds credentials placeholder' do
          expect(chef_run).to render_file(job_file_path)
            .with_content("#{scm.first.fetch(:credential).upcase}_CREDENTIAL_ID")
      end
    end

    %w( [] nil ).each do |v|
      describe "when scm is #{v}" do
        let(:scm){ eval(v) }
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
    end
  end

  # pending 'assigns the correct credentials to the file' do
  # expect(resource).to notify('ruby_block[assign-credential]').to(:run)
  # end
end

