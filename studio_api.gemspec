Gem::Specification.new do |s|
  s.name = %q{studio_api}
  s.version = File.read("VERSION").chomp
  s.summary = %q{Intuitive ruby bindings to Studio Api Interface.}
  s.description = %q{Studio Api makes it easier to use SuSE Studio (http://susestudio.com) via API.
            Instead of adapting each ActiveResource to its behavior and
            manually adding multipart file upload it wrapp in in Active
            Resource like interface. It is possible to define credentials
            for whole api, or use it per partes, so it allow using it for
            different studio users together.}

  s.files = `git ls-files`.split("\n").grep(/^[^test\/]/)
  s.test_files =`git ls-files`.split("\n").grep(/^(test\/)/)
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.rdoc_options = ['--line-numbers', "--main", "README"]
  s.authors = ["Josef Reidinger"]
  s.email = %q{jreidinger@suse.cz}
  s.homepage = "http://github.com/jreidinger/studio_api"
  s.license = ["GPLv2","The Ruby License"]
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "studio_api"

  s.add_dependency "activeresource", ">= 2.3.8"
  s.add_dependency "xml-simple", ">= 1.0.0"
  s.add_development_dependency "yard"
end

