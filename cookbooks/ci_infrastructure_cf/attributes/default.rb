
default[:ci_infrastructure_cf][:credentials] = [{
  name: 'delete_me',
  key: '''-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAup9qOen/x+2zd8RGSIHeJj/S6GR7wOrK4enNH9APKkyOkVw2
RKbSN7Fm1wrqCoQCHJl3Ro1Av5CtxkAAS57YDqj/j4lSIuj7NvQLRBB1E22P2GKH
joN1ZQP01FjZ6mfJtN92PUMa68yT6fm4Lhf91xr2rUL3F11yy/8xSFMU7HcjbhMJ
IOkWvB5W6t0KLY1aEa1Vi8XqwDlpXtYued8u3DDjCFfqopAiofoBpFgYiVYzhiEN
HxGR+OBIEhlCr7B60/3XJTqKrBkbFwFPTcXioHN4QP0OUMuHSLi4TgCqPlA5IrdG
bj3YdcirOqQY5mQohtswDw+JmKP9IMdAwotHEwIDAQABAoIBAQCScukkW3nKhcFR
WighXDBdabZzge8Pe/EMCbJbpaVQ91TlwywfAZ5z7/YZCMqSx/b0RIYySkSmT73e
lnjk3tkD4CD0nblkBdqlzCtPFW8aeN7p2qAv+P9V7x3gyXzwktPZ6YZbGt70bc0h
TkL3gQJFHDa5zpQitMWSSkd9Tx1bVedkmlLhFoNguhdZ1a/WbXRyKHK64T46effV
wBHvUDIXJ8tUxef8intisFs6qEb8onpvhNWl0I6MxwiTLxgRe29pTeQIgOH+tBDk
JuN526gxBRzDNxp14Gg/hae+KowwxhQUHgMFIT8nA4X1KRGhtbPHanyjXJs3mYU4
7rEJDV65AoGBAOZYFcKKuwzlGmgH9vu4qI6kKaMZY9HNoPZDvnBeOfR5tbNceb27
MddQnDpn+JM6GsqaXo+UZPZVboFyd1ctPcyPM5YoLiMyC64/6OUnK+S+wSW2AeV9
UVw10/T2M/YZIA5M8F80d4FhsFBBD5PwbS+RBC2pZdowXryRgBxnslX3AoGBAM9o
rlEElswsrMXJGAjZ4rRh/xnF5RI0RpgcmfoIdeheqKub8+8tePIEMqBt6LbCPs3n
f1hKQZ/oXkV3FJ2eu+OKr5it5dvu1vxVE/dmeaVp9y9+Nr/j+V5jv1lc5Tee4KYS
qMHjEPXB6hFKg1ZXJf1hRJ+zBo1LOgsPyyRL4eDFAoGAQtfI6L1tbl6FfS7ig0Wg
1FPbKVNS3i03yn76Io2Vb9Zp3fS191L9MahYzbIiNkckQyrsyemcKse726Cl9QxR
5Kyhoa9jRB9fuF8fbHAjkquwTQs2HaxyEbolGe7gQUglP0Egd+A31bnNelyG8r1Q
Uf9ZIQ8JWXmz5DCs5pFI9R0CgYEAuomNbXRRI6RyZxgrM5qy2ETiqA1hrnOxohDn
Mwb09F5eGKmURGKDSjcYSU1QZT5iOdGgqIlwaB8W2ib1NaWTmlwa/Zg5CQrP8/WY
lYNmmKyrEd3T49Vna8sOR5LS3KlZpkNV37sWf9E9cPuxD7AljLM0guUCWYV02IoF
y8krh3kCgYBqvbe0n6lTx8/fuBOnENKn5Sg5CplPAQsv/jjOwn1a73PHWFiRZ9P7
aS5HF5rDvGixW68knwKimOgKvNrk/BQyR2vNlONeRySn2PFxf/V+4WT43mBGO8Y1
+kF9Jvab7e84g8F4m0c/G/f4zhivOwmd3S8OEBmLQdE5wj0ux/Q+rw==
-----END RSA PRIVATE KEY-----'''
}]
default[:spiff][:url] = 'https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0/spiff_linux_amd64.zip'
default[:spiff][:version] = '1.0'

default[:ci_infrastructure_cf][:jobs][:microbosh].tap do |j|
    j[:provider][:name] = 'openstack|aws|etc'
    j[:provider][:user] = 'admin'
    j[:provider][:pass] = 'admin'
    j[:provider][:tenant] = 'dev'
    j[:provider][:auth_url]= 'https://example.com:5000/v2.0/tokens'
    j[:address][:subnet_id]= 'SUBNET_ID'
    j[:address][:ip]= 'IP'
    j[:build_cmd] = """
      rbenv local 1.9.3-p194
      echo '1\n' | bosh-bootstrap deploy
    """
end

microbosh = node[:ci_infrastructure_cf][:jobs][:microbosh]
bosh = node[:ci_infrastructure_cf][:jobs][:bosh]

default[:ci_infrastructure_cf][:jobs][:bosh].tap do |j|
  j[:scm]= [
      { url: 'https://github.com/cloudfoundry/bosh.git',
        credential: 'delete_me'
  }]
  j[:spiff_stub]=
    Mash.new(bosh.nil? ? {} : bosh[:spiff_stub].to_hash).deep_merge( {
    properties: {
      openstack: {
        auth_url: microbosh[:provider][:auth_url].gsub('/tokens',''),
        username: microbosh[:provider][:user],
        api_key: microbosh[:provider][:pass],
        tenant: microbosh[:provider][:tenant],
      }
    },
    meta: {
      recursor: microbosh[:address][:ip],
      networks: {
        cloud_properties: {
          net_id: microbosh[:address][:subnet_id]
        }
      }
    }
  })

  j[:build_cmd]=  """
    rbenv local 1.9.3-p194
    bosh -n target #{microbosh[:address][:ip]}
    bosh login admin admin
    bosh -n upload release $(pwd)/release/releases/bosh-93.yml --skip-if-exists
    ~/templates/bosh/generate_manifest ~/stubs/bosh.stub.yml
    ~/bin/set_director_uuid deployment.yml
    ~/bin/upload_stemcell

    bosh deployment deployment.yml
    bosh -n deploy
 """
end
default[:ci_infrastructure_cf][:hosts]
default[:rbenv][:user_installs] = [{ user: 'jenkins'}]
default['rbenv']['user_home_root'] = '/var/lib/'


