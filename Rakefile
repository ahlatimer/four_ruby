require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "four_ruby"
  gem.homepage = "http://github.com/ahlatimer/four_ruby"
  gem.license = "MIT"
  gem.summary = %Q{A Ruby API wrapper for Foursquare.}
  gem.description = %Q{A simple Ruby API wrapper for Foursquare.}
  gem.email = "andrew@elpasoera.com"
  gem.authors = ["Andrew Latimer"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
  
  gem.add_runtime_dependency 'httparty'
  gem.add_runtime_dependency 'hashie'
  gem.add_runtime_dependency 'oauth2'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["--color", "--format doc"]
end

namespace :spec do 
  desc "Run specs with RCov" 
  RSpec::Core::RakeTask.new('rcov') do |t|
    t.rspec_opts = ["--color"]
    t.rcov = true 
    t.rcov_opts = ['--exclude', '.rvm']
  end 
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "four_ruby #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
