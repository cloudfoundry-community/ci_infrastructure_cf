require_relative  '../../cookbooks/ci_infrastructure_cf/libraries/job_conf'

describe JobConf do
    let(:scm){ [ { 'credential' => 'something'}, {} ] }
    let(:job_name) { 'dummy' }
    let(:node) do
      {ci_infrastructure_cf:
        {jobs: {
          job_name => {
            scm: scm
      } } } }
    end
    let(:job_conf) { described_class.new(job_name, node) }

  describe '#credentials' do
    it 'removes nils' do
      expect(
        job_conf.credentials
      ).to eq(['something'])
    end
  end

end

