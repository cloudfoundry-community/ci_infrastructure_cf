require "thor"
require "bosh-deployer"

module CiInfrastructureCf
  class ThorCli < Thor

    desc "generate stub <NAME>", "Generates stub for bosh or cloudfoundry"
    def generate_stub(name)
      require "bosh-deployer/cli/commands/generate_stub"
      cmd = Bosh::Deployer::Cli::Commands::GenerateStub.new(
        name, 'cookbooks/ci_infrastructure_cf/files/default/stubs')

        cmd.perform
    end
  end
end
