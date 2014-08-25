module Kernel
  def install_chef_gem(name)
    begin
      gem name
    rescue LoadError
      system("gem install --no-rdoc --no-ri #{name}")
      Gem.clear_paths
    end
  end
end
