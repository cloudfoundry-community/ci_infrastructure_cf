module Kernel
  def install_chef_gem(name)
    begin
      gem 'cyoi'
    rescue LoadError
      system("gem install --no-rdoc --no-ri cyoi")
      Gem.clear_paths
    end
  end
end
