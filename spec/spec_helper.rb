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


RSpec.configure do |config|
end
