ENV['RACK_ENV'] ||= 'test'

require 'rspec'
require 'chefspec'
require 'chefspec/berkshelf'
require 'pry'


RSpec.configure do |config|
  config.before(:each) do
  end
end
