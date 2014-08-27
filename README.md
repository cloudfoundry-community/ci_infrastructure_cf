CI_INFRASTRUCTURE_CF
====================
[![Build Status](https://travis-ci.org/cloudfoundry-community/ci_infrastructure_cf.svg)](https://travis-ci.org/cloudfoundry-community/ci_infrastructure_cf)
[![Code Climate](https://codeclimate.com/github/cloudfoundry-community/ci_infrastructure_cf.png)](https://codeclimate.com/github/cloudfoundry-community/ci_infrastructure_cf)
[![Coverage Status](https://coveralls.io/repos/cloudfoundry-community/ci_infrastructure_cf/badge.png)](https://coveralls.io/r/cloudfoundry-community/ci_infrastructure_cf)
[![Dependency Status](https://gemnasium.com/cloudfoundry-community/ci_infrastructure_cf.svg)](https://gemnasium.com/cloudfoundry-community/ci_infrastructure_cf)

Provisions a jenkins machine on the cloud with a set of pre configured jobs that deploy Microbosh, Bosh and Cloudfoundry on demand.

## Motivation

As bosh operators we were facing repetitive processes to deploy a full infrastructure in different environments and regions manually. We also were setting the same attributes for different releases realising that our bosh deployment manifests share configurations between them. Another issue we were facing was the lack of an standarize deployment procedures between different members of the team.

## Goals

* Automation for Bosh deployments (Including Bosh and CloudFoundry out of the box).
* Reuse configurations between deployments. (eg: net_ids, network_ranges, etc)
* Keep full infrastructure configuration in a sigle place. (Provision via Vagrantfile)
* Automated updates and maintenance for bosh deployments.

## Disclaimer 

This project together with this documents aims to show goals and current state of the tool. We are not yet able to give support to the community and it will be over continue development till we can relese an stable versions.
We recomend trying it on a development environment.

### Technologies

* Chef
* Vagrant

### Plataform support

* Openstack

## Local pre deployment setup

###On Linux(Ubuntu 14.04)
Install dependencies:

```bash
  sudo apt-get update
  sudo apt-get install linux-headers-$(uname -r)
  sudo apt-get install git
  wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
  sudo dpkg -i vagrant_1.6.3_x86_64.deb
  sudo apt-get install virtualbox
  # ONLY FOR 12.04 =============
  sudo apt-get install python-software-properties 
  sudo add-apt-repository cloud-archive:icehouse
  sudo apt-get update
  sudo apt-get dist-upgrade
  # ============================
  sudo apt-get install python-novaclient  #pending to test
  wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.2.0-2_amd64.deb
  sudo dpkg -i chefdk_0.2.0-2_amd64.deb
  # Installs Quantum ===========
  sudo apt-get install language-pack-en
  sudo apt-get install python-quantumclient
  echo 'export LC_ALL=en_US.UTF-8' >> ~/.bashrc
  # ============================
```


###On OSX
Install dependencies:

```
TODO
```

###On Both:

Configure nova client:
```bash
  $ export OS_USERNAME=user
  $ export OS_PASSWORD=password
  $ export OS_TENANT_NAME=tenant
  $ export OS_AUTH_URL=https://example.keystone.com:5000/v2.0
```

Install Vagrant plugins:

```bash
  $ vagrant plugin install vagrant-berkshelf
  $ vagrant plugin install vagrant-openstack-plugin
  $ vagrant plugin install vagrant-omnibus
```

## Cloud pre deployment setup

###On openstack
1.  Create 2 networks
    - Internal (CF traffic)
    - External (CF >> Internet traffic)
2.  Create keypair for vagrant

    ```
      $ nova keypair-add vagrant > ~/.ssh/vagrant.pem
    ```
3.  Create Jenkins and SSH sec-groups
    
    ```
      $ nova secgroup-create jenkins "Jenkins sec group"
      $ nova secgroup-add-rule jenkins tcp 8080 8080 0.0.0.0/0
      $ nova secgroup-create ssh "SSH sec group"
      $ nova secgroup-add-rule ssh tcp 22 22 0.0.0.0/0
    ```
3.  Provision floating IP for Jenkins and for CF:

    ```
      $ nova floating-ip-create external #To be used for Jenkins
      +--------------+-----------+----------+----------+
      | Ip           | Server Id | Fixed Ip | Pool     |
      +--------------+-----------+----------+----------+
      | 1.1.1.2      |           | -        | external |
      +--------------+-----------+----------+----------+
      $ nova floating-ip-create external #To be used for CF
      +--------------+-----------+----------+----------+
      | Ip           | Server Id | Fixed Ip | Pool     |
      +--------------+-----------+----------+----------+
      | 1.1.1.3      |           | -        | external |
      +--------------+-----------+----------+----------+
    ```

##Attributes

- `node[:ci_infrastructure_cf][:jobs]` contains hashes were the keys are the jobname and the values are theirs configurations.

###For Microbosh:

See complete list of attributes at [attributes/microbosh.rb](https://github.com/cloudfoundry-community/ci_infrastructure_cf/blob/master/cookbooks/ci_infrastructure_cf/attributes/microbosh.rb).

####Required:

- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:name]` can be openstack|aws|vsphere. Default: `openstack`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:user]` provider username. Default: `admin`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:pass]` provider password. Default: `admin`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:tenant]` provider tenant. Default: `dev`.

- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:auth_url]` keystone url. Default: `https://example.com:5000/v2.0/tokens`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:subnet_id]` Internal subnet id. Default: `SUBNET_ID`.

###For Bosh:

See complete list of attributes at [attributes/bosh.rb](https://github.com/cloudfoundry-community/ci_infrastructure_cf/blob/master/cookbooks/ci_infrastructure_cf/attributes/bosh.rb).

####Required:

- `node[:ci_infrastructure_cf][:bosh][:spiff_stub][:meta][:networks][:manual][:static]` static network ip range. Sample: `['1.1.1.1 - 2.2.2.2']`
- `node[:ci_infrastructure_cf][:bosh][:spiff_stub][:meta][:networks][:manual][:range]` complete network range (Internal). Sample: `1.1.1.0/24`

###For CloudFoundry:

See complete list of attributes at [attributes/cloudfoundry.rb](https://github.com/cloudfoundry-community/ci_infrastructure_cf/blob/master/cookbooks/ci_infrastructure_cf/attributes/cloudfoundry.rb).

####Required:

- `node[:spiff_stub][:networks][:floating][:cloud_properties][:net_id]` External net id for floating network. Default: microbosh subnet id.
- `node[:spiff_stub][:meta][:floating_static_ips]` Array with floating static ips available. Sample: `['2.2.2.2']`

- 
```ruby
node[:spiff_stub][:networks][:cf1][:subnets]= [ 
  {
    name: 'default_unused',
    gateway: 'GATEWAY_IP',              # Sample: 1.1.1.1
    range: 'GATEWAY_RANGE',             # Sample: 1.1.1.1/24
    reserved: RESERVED_IP_RANGE_ARRAY,  # Sample: ['1.1.1.2 - 1.1.1.20'],
    static: STATIC_IP_RANGE_ARRAY,      # Sample: ['1.1.1.21 - 1.1.1.120'],
    cloud_properties:{
      net_id: MICROBOSH_SUBNET_ID,      # Sample: 2a88d7d9-bda5-47ef-ab04-2a3465fae123
      security_groups: ['cf-public', 'cf-private', 'ssh']
      
    }
  }
]
```

###For Custom jobs:

TODO

##Usage

Clone Repo:


```
  git clone https://github.com/cloudfoundry-community/ci_infrastructure_cf.git
  cd ci_infrastructure_cf/openstack
```

Export environment variables required on the vagrantfile:

  ```text
    # env_vars file
    export OS_USERNAME=admin
    export OS_PASSWORD=admin
    export OS_FLAVOR=m1.large
    export OS_IMAGE=ubuntu-14.04
    export OS_AUTH_URL=https://keystone.example:5001/v2.0
    export OS_KEYPAIR_NAME=vagrant
    export OS_NETWORK=internal
    export OS_TENANT_NAME=development
    export JENKINS_FLOATING_IP=1.1.1.2
    export MICROBOSH_SUBNET_ID=53e020ad-bc34-4126-be44-e0a3e2c04591
    export MICROBOSH_IP=FIXED_INTERNAL_IP
  ```
####Deploy:

```
  $ vagrant up --provider=openstack
```

##### Update configuration on the Vagrantfile.
##### Re-Provision VM

```
  $ vagrant provision
```

##### Re-Run tasks manually

Go to http://FIXED_JENKINS_IP:8080 :

![](https://github.com/cloudfoundry-community/ci_infrastructure_cf/blob/master/images/dashboard.png)

Run any task manually:

![](https://github.com/cloudfoundry-community/ci_infrastructure_cf/blob/master/images/microbosh.png)

## Troubleshooting on openstack
### Security groups quota limit exceeded:

if you get the following errror when running any of the tasks:

```json
  "409-{u'NeutronError': {u'message': u\\\"Quota exceeded for resources: ['security_group']\\\""}}"
```

You can try by changing the quota limts using admin credentials with the following command:

```bash
  $ neutron quota-update --tenant-id b5e6943e8280489wb86c4943a6a317ab --security-group 1000 --security-group-rule 100000
```

### VM creation failed:

message:

```
 Bosh::Clouds::VMCreationFailed (Bosh::Clouds::VMCreationFailed)
```

Possible causes:

- IP of one of the vms already taken.
- Not enough permissions on the openstack user.
