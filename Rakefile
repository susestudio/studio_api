require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

task :default => "test"

Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

begin
  require 'yard'
    YARD::Rake::YardocTask.new do |t|
      t.files   = ['lib/**/*.rb']   # optional
      t.options = [] # optional
    end
rescue LoadError
  puts "Yard not available. To generate documentation install it with: gem install yard"
end

