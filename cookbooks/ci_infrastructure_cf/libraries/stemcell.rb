require_relative 'provider'

class Chef
  class Resource::Stemcell < Resource::LWRPBase
    # identity_attr :id
    provides :stemcell

    # Set the resource name
    self.resource_name = :stemcell

    # Actions
    actions :download
    default_action :download

    attribute :stemcell_version,
      kind_of: String
    attribute :stemcell_name,
      kind_of: String
  end
end

class Chef
  class Provider::Stemcell < Provider::LWRPBase

    def load_current_resource
      @current_resource ||= Resource::Stemcell.new(new_resource.name)
      @current_resource.tap do |r|
        r.stemcell_version( new_resource.stemcell_version)
        r.stemcell_name(new_resource.stemcell_name)
      end
    end

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    def stemcell_manager
      CiInfrastructureCf::StemcellManager.new(
        @new_resource.stemcell_name,
        @new_resource.stemcell_version
      )
    end

    action(:download) do
      converge_by("Download #{new_resource}") do
        stemcell_manager.download
      end
    end
  end
end

Chef::Platform.set(
  resource: :stemcell,
  provider: Chef::Provider::Stemcell
)
