if defined?(ChefSpec)
  def run_replace_placeholder(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(
      :replace_placeholder,
      :run,
      resource_name)
  end
end
