require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'

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


begin
  require 'jeweler'
    Jeweler::Tasks.new do |s|
      s.name = %q{studio_api}
      s.summary = %q{Studio Api Interface.}
      s.description = %q{Studio Api makes it easier to use Studio via API.
                Instead of adapting each ActiveResource to its behavior and
                manually adding multipart file upload it wrapp in in Active
                Resource like interface. It is possible to define credentials
                for whole api, or use it per partes, so it allow using it for
                different studio users together.}

      s.files = FileList['[A-Z]*', 'lib/studio_api/*.rb','lib/studio_api.rb', 'test/**/*.rb']
      s.require_path = 'lib'
      s.test_files = Dir[*['test/*_test.rb','test/responses/*.xml']]
      s.has_rdoc = true
      s.extra_rdoc_files = ["README.rdoc"]
      s.rdoc_options = ['--line-numbers', "--main", "README.rdoc"]
      s.authors = ["Josef Reidinger"]
      s.email = %q{jreidinger@suse.cz}
      s.homepage = "http://github.com/jreidinger/studio_api"
      s.add_dependency "activeresource", ">= 1.3.8"
      s.add_dependency "xml-simple", ">= 1.0.0"
      s.platform = Gem::Platform::RUBY
    end
    Jeweler::GemcutterTasks.new

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
rescue LoadError
  puts "Jeweler not available. To generate gem install it with: gem install jeweler"
end
