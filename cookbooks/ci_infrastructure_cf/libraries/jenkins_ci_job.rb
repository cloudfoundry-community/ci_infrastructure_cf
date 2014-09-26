require_relative 'job_conf'
install_chef_gem 'deep_merge'
require 'deep_merge'

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

    def job_conf
      @job_conf ||= JobConf.new(new_resource.name, node)
    end

    def job_file_path
      ::File.join(Chef::Config[:file_cache_path], job_conf.filename)
    end

    def default_stub
      file_path= "#{Chef::Config[:cookbook_path].first}/ci_infrastructure_cf/stubs/#{job_conf.name}.stub.yml"
      file_content = if ::File.file?(file_path)
                       ::File.read(file_path)
                     else
                       '{}'
                     end
      ::YAML.load(file_content)
    end

    def stub_content
      sc = default_stub.deep_merge(job_conf.spiff_stub.to_hash)
      if sc.has_key?('networks')
      networks = sc.delete('networks')
      new_networks = networks.collect{ |k,v| v.merge('name' => k)}
      # binding.pry
      sc.merge!('networks' => new_networks)
      end
      sc.to_yaml
    end

    action(:create) do
      converge_by("Create #{new_resource}") do
        template job_file_path do
          source 'jenkins_job.xml.erb'
          variables({ jobname: job_conf.name })
          mode 00666
        end


        if job_conf.has_scm?
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
            #{job_conf.credentials}.each{ cn ->
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

        # generate_stub if File.exists?()
        # Deep merge of spiff_stub provided via vagrantfile with default spiff_stub
        file "/var/lib/jenkins/stubs/#{job_conf.name}.stub.yml" do
          #TODO: Test gsub
          content stub_content.gsub(' ! ', ' ')
        end

        jenkins_job job_conf.name.capitalize do
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
