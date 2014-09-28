require_relative '../../lib/ci_infrastructure_cf/thor_cli'
require 'bosh-deployer'
#require 'bosh-deployer/cli/commands/generate_stub'

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

  describe 'edit_stub' do
    before{ allow(File).to receive(:exist?).and_return(true) }
    let(:default_path) do
      File.expand_path( "../../../lib/ci_infrastructure_cf/cookbooks/ci_infrastructure_cf/files/default/stubs", __FILE__)
    end
    %w{ bosh cf }.each do |stub|

      it "opens editor with the #{stub} stub" do
        expect(cli).to receive('spawn_and_wait')
          .with("vim #{default_path}/#{stub}.yml")
        cli.edit_stub(stub)
      end
    end
  end

  describe 'provision' do
    it "opens performs a vagrant provision" do
      expect(cli).to receive('spawn_and_wait')
        .with("vagrant provision")
      cli.provision
    end
  end

  describe 'deploy_jenkins'
  describe 'deploy_microbosh'
end
