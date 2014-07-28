require 'chef'
require_relative  '../../cookbooks/ci_infrastructure_cf/libraries/jenkins_ci_job'

describe 'Chef::Provider::JenkinsCiJob' do
    let(:jenkins_ci_job) do
      cookbook = double('cookbook').as_null_object
      block = double('block').as_null_object
    end
    let(:scm){ [ { credential: 'something'}, {} ] }

  describe '#collect_credentials' do
    it 'removes nils' do
      expect(
        Chef::Provider::JenkinsCiJob.collect_credentials(scm)
      ).to eq(['something'])
    end
  end

end

