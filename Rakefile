require 'rspec/core/rake_task'
require 'berkshelf'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
task :build do
  # berksfile = Berkshelf::Berksfile.from_file('Berksfile')
  # berksfile.install path: "vendor/cookbooks"
  ENV['BERKSHELF_PATH'] = 'vendor'
  Berkshelf::Berksfile.from_file('Berksfile').install
end
