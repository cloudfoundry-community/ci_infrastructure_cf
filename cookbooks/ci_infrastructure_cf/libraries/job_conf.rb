require 'ostruct'

class JobConf < OpenStruct
  attr_reader :name, :filename

  def initialize(job_name, node)
    @name = job_name.downcase
    @filename = "#{@name}_job.xml"
    super(node[:ci_infrastructure_cf][:jobs][@name])
  end

  def has_scm?
    !scm.nil? and !scm.empty?
  end

  def credentials
    scm.collect do |repo|
      repo['credential']
    end.compact
  end
end
