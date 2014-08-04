
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
    def self.collect_credentials(scm)
      scm.collect do |repo|
        repo[:credential]
      end.compact
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
          mode 00666
        end


        unless conf[:scm].nil? or conf[:scm].empty?
          credentials = self.class.collect_credentials(conf[:scm])
          jenkins_script 'get_credential_id' do
            command <<-EOH.gsub(/^ {4}/, '')
           import jenkins.model.*
           import hudson.security.*
           import org.jenkinsci.plugins.*
           import java.nio.file.*
           import java.nio.charset.*

           def instance = Jenkins.getInstance()
            def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
                  com.cloudbees.plugins.credentials.common.StandardUsernameCredentials.class,
                  instance,
                  null,
                  null
                  );
            #{credentials}.each{ cn ->
              println(creds[0].dump())
              println(creds.dump())
              def id = creds.find{c -> c.username == cn }.id
              def path = Paths.get("#{job_file_path}");
              def charset = StandardCharsets.UTF_8;
              def content = new String(Files.readAllBytes(path), charset);
              content = content.replaceAll(cn.toUpperCase() +"_CREDENTIAL_ID",  id );
              Files.write(path, content.getBytes(charset));
            }
            EOH
          end
        end


        template 'bosh-stub' do
          path "/var/lib/jenkins/stubs/bosh.stub.yml"
          source 'bosh.stub.yml.erb'
          owner 'jenkins'
          group 'jenkins'
          mode 00640
        end if job_name == 'bosh'

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
