jenkins_private_key_credentials 'infrastructure-prototypes' do
  private_key node[:ci_infrastructure_cf][:credentials][:infrastructure_prototypes]
  notifies :write, 'log[create-credential-msg]', :immediately
end

log 'create-credential-msg' do
  message 'creating credentials'
  action :nothing
end

jenkins_script 'get_credential_id' do
  command <<-EOH.gsub(/^ {4}/, '')
   import jenkins.model.*
   import hudson.security.*
   import org.jenkinsci.plugins.*

   def instance = Jenkins.getInstance()
    def creds = com.cloudbees.plugins.credentials.CredentialsProvider.lookupCredentials(
          com.cloudbees.plugins.credentials.common.StandardUsernameCredentials.class,
          instance,
          null,
          null
          );

    id = creds[0].id

    new File("/tmp/credentials").withWriter { out ->
      out.writeLine("${id}")
    }
  EOH
end
# cookbook_file bosh_xml do
  # source "bosh_job.xml"
  # notifies :run, 'ruby_block[assign-credential]', :immediately
# end

# ruby_block 'assign-credential' do
  # block do
     # credentials_file = '/tmp/credentials'
     # if File.exists?(credentials_file) && File.exists?(bosh_xml)
       # id = `tail -n 2 #{credentials_file}`.strip
       # xml = File.read(bosh_xml)
       # xml.gsub!('CREDENTIAL_ID_PLACEHOLDER', id)
       # File.open(bosh_xml, 'w') { |f| f.write(xml) }
     # else
       # "BANG"
     # end

  # end
# end
