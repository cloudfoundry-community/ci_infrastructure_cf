install_chef_gem 'cyoi'
require 'cyoi/providers'
require 'cyoi/providers/clients/openstack_provider_client'
require 'readwritesettings'
require 'forwardable'

module CiInfrastructureCf
  class Provider
    extend Forwardable
    def_delegators :client, :create_security_group

    def client
      @client ||= Cyoi::Providers.provider_client(settings)
    end

    private
    def settings
      YAML.load_file(settings_file).to_hash.fetch('provider')
    end

    def settings_file
        '/var/lib/jenkins/.microbosh/settings.yml'
    end
  end
end
