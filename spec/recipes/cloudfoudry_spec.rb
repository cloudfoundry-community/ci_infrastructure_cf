require 'spec_helper'

class Hash
  def sort_by_key(recursive = false, &block)
    self.keys.sort(&block).reduce({}) do |seed, key|
      seed[key] = self[key]
      if recursive && seed[key].is_a?(Hash)
        seed[key] = seed[key].sort_by_key(true, &block)
      end
      seed
    end
  end
end

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
            subnets: {
            default_unused: {
              gateway: '1.1.1.1',
              reserved: ['1.1.1.1 - 2.2.2.2'],
              static: ['2.2.2.2 - 3.3.3.3']
            }
            }
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
end
