module CiInfrastructureCf
  class StemcellManager
    attr_reader :name, :version
    def initialize(name, version)
      @name = name
      @version = version
    end

    def download
      system("wget --timeout=10 -q #{url} -P /var/lib/jenkins/stemcells")
    end

    private
    def url
      if os != 'centos'
        "https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/#{cloud}/bosh-stemcell-#{version}-#{cloud}-#{virtualization_type}-#{os}-#{os_version}-go_agent.tgz"
      else
        "https://s3.amazonaws.com/bosh-jenkins-artifacts/bosh-stemcell/#{cloud}/bosh-stemcell-#{version}-#{cloud}-#{virtualization_type}-#{os}-go_agent.tgz"
      end
    end
    #
    def cloud
      name_attrs[1]
    end

    def virtualization_type
      name_attrs[2]
    end

    def os
      name_attrs[3]
    end

    def os_version
      name_attrs[4]
    end

    def name_attrs
      @name_attrs ||= name.split('-')
    end
  end
end


