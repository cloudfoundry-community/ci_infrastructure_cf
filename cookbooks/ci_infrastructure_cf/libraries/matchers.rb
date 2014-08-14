if defined?(ChefSpec)
  def run_replace_placeholder(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :replace_placeholder,
      :run,
      resource_name)
  end

  def create_jenkins_ci_job(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :jenkins_ci_job,
      :create,
      resource_name)
  end

  def create_sec_group(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :sec_group,
      :create,
      resource_name)
  end

  def download_stemcell(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :stemcell,
      :download,
      resource_name)
  end
end
