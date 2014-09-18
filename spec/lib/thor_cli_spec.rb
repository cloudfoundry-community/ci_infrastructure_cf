require_relative '../../lib/ci_infrastructure_cf/thor_cli'
require 'bosh-deployer/cli/commands/generate_stub'

describe CiInfrastructureCf::ThorCli do
  let(:cli){ described_class.new }

  describe 'generate_stub' do
    let(:cmd){ double.as_null_object }

    it 'should called generate stub with the correct commands' do
      expect(Bosh::Deployer::Cli::Commands::GenerateStub)
        .to receive(:new).with('bosh',anything).and_return(cmd)
        cli.generate_stub('bosh')
    end
  end

  describe 'edit_stub'
  describe 'deploy_jenkins'
  describe 'deploy_microbosh'
end
