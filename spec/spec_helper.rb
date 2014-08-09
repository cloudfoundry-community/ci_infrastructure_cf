require 'coveralls'
Coveralls.wear!

require 'rspec'
require 'chefspec'
require 'chefspec/berkshelf'
# require 'berkshelf'

# Berkshelf.ui.mute do
  # ENV['BERKSHELF_PATH'] = 'vendor'
  # Berkshelf::Berksfile.from_file('Berksfile').install
# end

require 'chefspec/cacher'
require 'pry'

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

RSpec.configure do |config|
end
