require 'spec_helper'

describe 'ci_infrastructure_cf::microbosh' do
  let(:chef_run) { ChefSpec::Runner.new.converge(described_recipe) }

  describe 'when creating xml file' do
    let(:filename){ 'microbosh_job.xml' }
    let(:config_file){ File.join(Chef::Config[:file_cache_path], filename) }
    let(:resource) do
      chef_run.find_resource( :template, config_file)
    end

    %w{libmysqlclient-dev libpq-dev}.each do |pkg|
      it "install #{pkg} package" do
        expect(chef_run).to install_package(pkg)
      end
    end

    it 'chowns the rbenv dir' do
      expect(chef_run).to run_execute("chown-rbenv-dir")
    end

    it 'creates the file' do
      expect(chef_run).to create_template(config_file)
    end

    pending 'assigns the correct credentials to the file' do
      expect(resource).to notify('ruby_block[assign-credential]').to(:run)
    end

  end

  %w{fog bundler bosh-bootstrap}.each do |gem|
    it "installs #{gem}" do
      expect(chef_run).to install_rbenv_gem(gem)
    end
  end

  it 'creates microbosh task' do
    expect_any_instance_of(Chef::Recipe).to receive(:jenkins_job).with('Microbosh')
    chef_run
  end

  describe 'creating setting tmplates' do
    let(:settings_dir) { '/var/lib/jenkins/.microbosh' }
    let(:settings_path){ "#{settings_dir}/settings.yml" }
    let(:chef_run) do
      ChefSpec::Runner.new do |node|
        node.set[:ci_infrastructure_cf][:jobs][:microbosh].tap do |n|
          n[:provider][:name] = 'custom_infra'
          n[:provider][:user] = 'custom_user'
          n[:provider][:pass] = 'custom_pass'
          n[:provider][:tenant] = 'custom_tenant'
          n[:provider][:auth_url] = 'custom_auth_url'
          n[:address][:subnet_id] = 'custom_subnet_id'
          n[:address][:ip] = 'custom_ip'
        end
      end.converge(described_recipe)
    end

    it 'creates the settings folder' do
      expect(chef_run).to create_directory(settings_dir)
    end

    {
      provider_name: 'name: custom_infra',
      provider_user: 'openstack_username: custom_user',
      provider_pass: 'openstack_api_key: custom_pass',
      provider_tenant: 'openstack_tenant: custom_tenant',
      provider_auth_url: 'openstack_auth_url: custom_auth_url',
      address_subnet_id: 'subnet_id: custom_subnet_id',
      address_ip: 'ip: custom_ip'
    }.each_pair do |resource, content|
      it "sets the #{resource} correctly" do
        expect(chef_run).to render_file(settings_path)
          .with_content(content)
      end
    end
  end
end
