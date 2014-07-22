class Chef
  class Resource::ReplacePlaceholder < Resource::LWRPBase
    identity_attr :placeholder

    provides :replace_placeholder

    # Set the resource name
    self.resource_name = :replace_placeholder

    # Actions
    actions :run
    default_action :run

    attribute :source,
      kind_of: String,
      required: true
    attribute :placeholder,
      kind_of: String,
      name_attribute: true
    attribute :replace_with,
      kind_of: String,
      required: true
  end
end

class Chef
  class Provider::ReplacePlaceholder < Provider::LWRPBase

    def load_current_resource
      @current_resource ||= Resource::ReplacePlaceholder.new(new_resource.name)
      @current_resource.tap do |r|
        r.name(new_resource.name)
        r.source(new_resource.source)
        r.placeholder(new_resource.placeholder)
        r.replace_with(new_resource.replace_with)
      end
    end

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    action(:run) do
      converge_by("Run #{new_resource}") do
        xml = ::File.read(new_resource.source)
        xml.gsub!(new_resource.placeholder, new_resource.replace_with)
        ::File.open(new_resource.source, 'w') { |f| f.write(xml) }
      end
    end
  end
end

Chef::Platform.set(
  resource: :replace_placeholder,
  provider: Chef::Provider::ReplacePlaceholder
)
