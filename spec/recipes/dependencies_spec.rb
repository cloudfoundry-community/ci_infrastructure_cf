require 'spec_helper'

describe 'ci_infrastructure_cf::dependencies' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['rbenv']['install_pkgs'] = %w{git-core grep}
    end.converge(described_recipe)
  end

  %w{ rbenv::user_install ruby_build }.each do |recipe|
    it "includes receipe #{recipe}" do
      expect(chef_run).to include_recipe(recipe)
    end
  end

  describe 'when installing ruby' do
    it 'installs ruby' do
      expect(chef_run).to install_rbenv_ruby('1.9.3-p194')
    end

    it 'set it up for the jenkins user' do
      expect(chef_run.node[:rbenv][:user_installs]).to include(user: 'jenkins')
    end
  end

  describe 'enabling connections via CLI' do
    let(:jenkins_conf){ '' }
    let(:resource) do
      chef_run.find_resource(:ruby_block, 'enable-cli')
    end

    before do
      allow(File).tap do |f|
        f.to receive(:exists?).and_call_original
        f.to receive(:exists?).with('/etc/default/jenkins')
        .and_return(true)
        f.to receive(:read).with(anything).and_call_original
        f.to receive(:read).with('/etc/default/jenkins')
        .and_return(jenkins_conf)
      end
    end

    describe 'when JAVA_ARGS were not change' do
      let(:jenkins_conf){ 'JAVA_ARGS=""' }

      it 'does change /etc/default/jenkins' do
        expect(chef_run).to run_ruby_block 'enable-cli'
      end
    end

    describe 'when JAVA_ARGS were already change' do
      let(:jenkins_conf){ 'JAVA_ARGS="-Dhudson.diyChunking=false"' }

      it 'does not change /etc/default/jenkins' do
        expect(chef_run).not_to run_ruby_block 'enable-cli'
      end
    end

    it 'defines enable-cli resource' do
      expect(resource).to be
    end

    it 'restart jenkins after enableing ' do
      expect(resource).to notify('service[jenkins]').to(:restart)
    end

    it 'logs an info message' do
      expect(resource).to notify('log[enable-cli-msg]').to(:write)
    end

    it 'defines enable-cli-msg resource' do
      expect(chef_run.find_resource(:log,
                                    'enable-cli-msg')).to be
    end
  end


  describe 'when installing spiff' do
    let(:resource) do
      chef_run.find_resource(:remote_file, 'spiff')
    end

    it 'brings the remote file' do
      expect(chef_run).to create_remote_file('spiff')
    end


    it 'makes it available for jenkins in the path' do
      expect(chef_run).to run_execute('unzip-spiff')
    end
  end

  %w{git unzip}.each do |pkg|
    it "installs git #{pkg}" do
      expect(chef_run).to install_package pkg
    end
  end

  describe 'git-client plugin' do
    it 'installs plugin' do
      expect(chef_run).to install_jenkins_plugin 'git-client'
    end
  end

  describe 'jenkins safe restart' do
    let(:resource) do
      chef_run.find_resource(:jenkins_command,
                             'safe-restart')
    end

    it 'defines safe-restart resource' do
      expect(resource).to be
    end

    it 'notifies on safe-restart to wait-for-jenkins'  do
      expect(resource).to notify('execute[wait-for-jenkins]').to(:run).immediately
    end
  end

  it 'defines wait-for-jenkins resource' do
    resource = chef_run.find_resource(:execute,
                                      'wait-for-jenkins')
    expect(resource).to be
  end

  describe 'git plugin' do
    let(:resource) do
      chef_run.find_resource(:jenkins_plugin, 'git')
    end

    it 'installs plugin' do
      expect(chef_run).to install_jenkins_plugin 'git'
    end

    it 'enables the plugin' do
      expect(chef_run).to enable_jenkins_plugin 'git'
    end

    it 'restart jenkins after enableing plugin' do
      expect(resource).to notify('jenkins_command[safe-restart]').to(:execute)
    end
  end
end
