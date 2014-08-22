CI_INFRASTRUCTURE_CF
====================
[![Build Status](https://travis-ci.org/cloudfoundry-community/ci_infrastructure_cf.svg)](https://travis-ci.org/cloudfoundry-community/ci_infrastructure_cf)
[![Code Climate](https://codeclimate.com/github/cloudfoundry-community/ci_infrastructure_cf.png)](https://codeclimate.com/github/cloudfoundry-community/ci_infrastructure_cf)
[![Coverage Status](https://coveralls.io/repos/cloudfoundry-community/ci_infrastructure_cf/badge.png)](https://coveralls.io/r/cloudfoundry-community/ci_infrastructure_cf)
[![Dependency Status](https://gemnasium.com/cloudfoundry-community/ci_infrastructure_cf.svg)](https://gemnasium.com/cloudfoundry-community/ci_infrastructure_cf)

Provisions a jenkins machine on the cloud with a set of pre configured jobs that deploy Microbosh, Bosh and Cloudfoundry on demand.

## Goals

* Automation for Bosh deployments (Including Bosh and CloudFoundry out of the box).
* Reuse configurations between deployments. (eg: net_ids, network_ranges, etc)
* Keep full infrastructure configuration in a sigle place.
* Automated updates and maintenance for bosh deployments.

### Technologies

* Chef
* Vagrant

### Plataform support

* Openstack

## Local pre deployment setup

###On Linux(Ubuntu 14.04)
Install dependencies:

```bash
  $ sudo apt-get update
  $ sudo apt-get install linux-headers-$(uname -r)
  $ sudo apt-get install git
  $ sudo apt-get install vagrant
  wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.3_x86_64.deb
  sudo dpkg -i vagrant_1.6.3_x86_64.deb
  sudo apt-get install virtualbox
  # ONLY FOR 12.04 =============
  sudo apt-get install python-software-properties 
  sudo add-apt-repository cloud-archive:icehouse
  sudo apt-get update
  sudo apt-get dist-upgrade
  # =============
  $ sudo apt-get install python-novaclient  #pending to test
  $ wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.2.0-2_amd64.deb
  $ sudo dpkg -i chefdk_0.2.0-2_amd64.deb
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
  $ export OS_FLAVOR=m1.large
  $ export OS_IMAGE=ubuntu-14.04
  $ export OS_KEYPAIR_NAME=vagrant_west
  $ export OS_NETWORK=internal
  $ export JENKINS_FLOATING_IP=
  $ export MICROBOSH_SUBNET_ID=
  $ export MICROBOSH_IP=
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
3.  Provision fixed ip for CF using the nova client:

    ```
      $ TODO
    ```

##Attributes

- `node[:ci_infrastructure_cf][:jobs]` contains hashes were the keys are the jobname and the values are theirs configurations.

###For Microbosh:

See complete list of attributes at attributes/microbosh.rb.

####Required:

- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:name]` can be openstack|aws|vsphere. Default: `openstack`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:user]` provider username. Default: `admin`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:pass]` provider password. Default: `admin`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:tenant]` provider tenant. Default: `dev`.

- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:auth_url]` keystone url. Default: `https://example.com:5000/v2.0/tokens`.
- `node[:ci_infrastructure_cf][:jobs][:microbosh][:provider][:subnet_id]` Internal subnet id. Default: `SUBNET_ID`.

###For Bosh:

See complete list of attributes at attributes/bosh.rb.

####Required:

- `node[:ci_infrastructure_cf][:bosh][:spiff_stub][:meta][:networks][:manual][:static]` static network ip range. Sample: `['1.1.1.1 - 2.2.2.2']`
- `node[:ci_infrastructure_cf][:bosh][:spiff_stub][:meta][:networks][:manual][:range]` complete network range (Internal). Sample: `1.1.1.0/24`

###For CloudFoundry:
See complete list of attributes at attributes/cloudfoundry.rb.

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
  cd ci_infrastructure_cf/
```


