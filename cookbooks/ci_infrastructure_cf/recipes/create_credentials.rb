node[:ci_infrastructure_cf][:credentials].each do |c|
  jenkins_private_key_credentials c.fetch(:name) do
    private_key c.fetch(:key)
    action [:delete, :create]

    notifies :write, 'log[create-credential-msg]', :immediately
  end
end

log 'create-credential-msg' do
  message 'creating credentials'
  action :nothing
end

