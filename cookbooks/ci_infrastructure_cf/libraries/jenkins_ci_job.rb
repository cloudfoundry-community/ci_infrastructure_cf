
class Chef
  class Resource::JenkinsCiJob < Resource::LWRPBase
    identity_attr :name
    provides :jenkins_ci_job

    # Set the resource name
    self.resource_name = :jenkins_ci_job

    # Actions
    actions :create
    default_action :create

    attribute :name,
      kind_of: String,
      name_attribute: true
    attribute :source,
      kind_of: String
  end
end

class Chef
  class Provider::JenkinsCiJob < Provider::LWRPBase

    def load_current_resource
      @current_resource ||= Resource::JenkinsCiJob.new(new_resource.name)
      @current_resource.tap do |r|
        r.name(new_resource.name)
        r.source(new_resource.source)
      end

    end

    #
    # This provider supports why-run mode.
    #
    def whyrun_supported?
      true
    end

    action(:create) do
      converge_by("Create #{new_resource}") do
        job_name = new_resource.name.downcase
        conf = node[:ci_infrastructure_cf][:jobs][job_name]
        job_filename = "#{job_name}_job.xml"
        job_file_path = ::File.join(Chef::Config[:file_cache_path], job_filename)
        template job_file_path do
          source 'jenkins_job.xml.erb'
          variables({ jobname: job_name })
        end
        jenkins_job job_name.capitalize do
          action :create
          config job_file_path
        end
      end
    end
    private
  end
end

Chef::Platform.set(
  resource: :jenkins_ci_job,
  provider: Chef::Provider::JenkinsCiJob
)
