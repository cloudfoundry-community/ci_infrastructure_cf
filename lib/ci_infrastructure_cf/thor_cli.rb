require "thor"
require "bosh-deployer"
      require "bosh-deployer/cli/commands/generate_stub"
module CiInfrastructureCf
  class ThorCli < Thor

    desc "generate_stub <NAME>", "Generates stub for bosh or cloudfoundry"
    def generate_stub(name)
      cmd = Bosh::Deployer::Cli::Commands::GenerateStub.new(
        name, default_path )
        cmd.perform
    end

    desc "edit_stub <NAME>", "Edit stub"
    def edit_stub(name)
      filepath = "#{default_path}/#{name}.yml"
      if File.exist?(filepath)
        spawn_and_wait("vim #{filepath}")
      else
        puts 'stub not found' 
      end
    end

    desc "provision", "Provision jenkins machine for cf ci"
    def provision
      spawn_and_wait("vagrant provision")
    end

    protected
    def default_path
      File.expand_path( "../../../cookbooks/ci_infrastructure_cf/files/default/stubs", __FILE__)
    end

    def spawn_and_wait(cmd)
      pid = spawn(cmd)
      Process.wait(pid)
    end
  end
end
