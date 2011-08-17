require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

task :default => "test"

desc "Create package directory containing all things to build RPM"
task :package => [:build] do
  pkg_name = "rubygem-studio_api"
  include FileUtils::Verbose
  rm_rf "package"
  mkdir "package"
  cp "#{pkg_name}.changes","package/"
  cp "#{pkg_name}.spec.template","package/#{pkg_name}.spec"
  sh 'cp pkg/*.gem package/'
  sh "sed -i \"s:<VERSION>:`cat VERSION`:\" package/#{pkg_name}.spec"
end

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

