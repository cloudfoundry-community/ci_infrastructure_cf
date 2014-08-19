require 'spec_helper'


describe 'ci_infrastructure_cf::cloudfoundry' do
  let(:chef_run) do
    ChefSpec::Runner.new(step_into: ['jenkins_ci_job']) do |n|
      n.set['ci_infrastructure_cf'][ 'jobs']['cloudfoundry']= job_attrs
      n.set['ci_infrastructure_cf'][ 'jobs']['bosh']=
      {spiff_stub: {
        meta: {
          networks: {
            manual: {
              range: '10.0.0.0/8'
            }
          }
        }
      }}
      n.set['ci_infrastructure_cf'][ 'jobs']['microbosh']=
      {address: {
        subnet_id: 'MICROBOSH_SUBNET_ID'
      }}
    end.converge(described_recipe)
  end

  let(:job_attrs){{}}


  describe 'when creates sec_groups' do
    it 'creates cf-private udp permissions' do
      expect(chef_run).to create_sec_group('cf-private-udp').with(
        sg_name: 'cf-private',
        protocol: 'udp',
        ports: [68, 3456]
      )
    end

    it 'creates cf-private udp permissions' do
      expect(chef_run).to create_sec_group('cf-private-tcp').with(
        sg_name: 'cf-private',
        protocol: 'tcp',
        ports: (1..65535).to_a
      )
    end
    it 'creates cf-public tcp'
    it 'creates cf-public udp'
  end
  it 'creates cloudfoundry jenkins ci job' do
    expect(chef_run).to create_jenkins_ci_job('CloudFoundry')
  end

  describe 'when spiff_stub is provided via attributes' do
    let(:job_attrs) do
      {spiff_stub: {
        meta:{
        floating_static_ips: [ '1.2.3.4' ]
        },
        networks:{
          cf1:{
            subnets: [{
              name: 'default_unused',
              range: '10.0.0.0/8',
              gateway: '1.1.1.1',
              reserved: ['1.1.1.1 - 2.2.2.2'],
              static: ['2.2.2.2 - 3.3.3.3'],
              cloud_properties:{
                net_id: 'MICROBOSH_SUBNET_ID',
                security_groups: [ 'cf-public', 'cf-private', 'ssh']
              }}
            ]
          }
        },
        jobs:{
          ha_proxy_z1:{
            properties:{
              ha_proxy:{
                ssl_pem: "KEY\nCERTIFICATE"
              }
            }
          }
        },
        properties: {
          uaa:{
            jwt: {
              signing_key: "KEY\nKEY",
              verification_key: "KEY\nKEY"
            }
          }
        }
      }}
    end

    it 'merges stub provided via vagrantfile' do
      resource = chef_run.find_resource(:file, '/var/lib/jenkins/stubs/cloudfoundry.stub.yml')
      @actual_content = ChefSpec::Renderer.new(chef_run, resource).content
      @expected_content = File.read('spec/assets/cloudfoundry.stub.yml')

      actual = YAML.load(@actual_content).sort_by_key(true).to_a
      expected = YAML.load(@expected_content).sort_by_key(true).to_a

      expect(expected).to eq(actual)
    end
  end

  describe 'when downloading stemcell' do
      before do
        allow(File).to receive(:exists?).and_call_original
        allow(File).to receive(:exists?)
        .with('/var/lib/jenkins/stubs/cloudfoundry.stub.yml')
        .and_return(true)
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read)
        .with('/var/lib/jenkins/stubs/cloudfoundry.stub.yml')
        .and_return( """
---
meta:
  stemcell:
    name: #{name}
    version: #{version}""")
      end
    [{
      name: 'bosh-openstack-kvm-ubuntu-trusty',
      version: 'latest'
    },{
      name: 'bosh-openstack-kvm-ubuntu-lucid-go_agent',
      version: 'latest'
    }].each do |s|
      describe "when downloading stemcell #{s[:name]} with version #{s[:version]}" do
        let(:name){ s[:name]}
        let(:version){ s[:version]}

        it 'downloads stemcell' do
          expect(chef_run).to download_stemcell('download-stemcell').with(
            stemcell_version: s[:version],
            stemcell_name: s[:name]
          )
        end
      end
    end



  end
end
