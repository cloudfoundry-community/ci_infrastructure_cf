require 'spec_helper'
require_relative '../../cookbooks/ci_infrastructure_cf/libraries/stemcell_manager'

describe CiInfrastructureCf::StemcellManager do
  let(:stemcell){described_class.new(name, version) }

  [{
    name: 'bosh-openstack-kvm-ubuntu-lucid',
    version: 'latest',
    expected_url: 'https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/openstack/bosh-stemcell-latest-openstack-kvm-ubuntu-lucid-go_agent.tgz'
  },
  {
    name: 'bosh-openstack-kvm-ubuntu-lucid-go_agent',
    version: 'latest',
    expected_url: 'https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/openstack/bosh-stemcell-latest-openstack-kvm-ubuntu-lucid-go_agent.tgz'
  },
  {
    name: 'bosh-aws-xen-centos-go_agent',
    version: 'latest',
    expected_url: 'https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/aws/bosh-stemcell-latest-aws-xen-centos-go_agent.tgz'
  },
  {
    name: 'bosh-openstack-kvm-ubuntu-trusty-go_agent',
    version: 'latest',
    expected_url: 'https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/openstack/bosh-stemcell-latest-openstack-kvm-ubuntu-trusty-go_agent.tgz'
  }].each do |s|
    describe "#download for #{s[:name]}" do
      let(:version) { s[:version] }
      let(:name) { s[:name] }
      let(:expected_url) { s[:expected_url] }

      it 'downloads stemcell' do
        expect(stemcell).to receive(:system)
          .with("wget --timeout=10 -q #{expected_url}")
        stemcell.download
      end
    end
  end

  describe '#upload_to_bosh' do
  end
end
