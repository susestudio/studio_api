# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{studio_api}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Josef Reidinger"]
  s.date = %q{2010-11-29}
  s.description = %q{Studio Api makes it easier to use Studio via API.
                Instead of adapting each ActiveResource to its behavior and
                manually adding multipart file upload it wrapp in in Active
                Resource like interface. It is possible to define credentials
                for whole api, or use it per partes, so it allow using it for
                different studio users together.}
  s.email = %q{jreidinger@suse.cz}
  s.files = [
    "README",
     "Rakefile",
     "VERSION",
     "lib/example.rb",
     "lib/studio_api.rb",
     "lib/studio_api/appliance.rb",
     "lib/studio_api/build.rb",
     "lib/studio_api/connection.rb",
     "lib/studio_api/file.rb",
     "lib/studio_api/generic_request.rb",
     "lib/studio_api/package.rb",
     "lib/studio_api/pattern.rb",
     "lib/studio_api/repository.rb",
     "lib/studio_api/rpm.rb",
     "lib/studio_api/running_build.rb",
     "lib/studio_api/studio_resource.rb",
     "lib/studio_api/template_set.rb",
     "lib/studio_api/util.rb",
     "lib/test.rb",
     "test/appliance_test.rb",
     "test/build_test.rb",
     "test/connection_test.rb",
     "test/file_test.rb",
     "test/generic_request_test.rb",
     "test/repository_test.rb",
     "test/resource_test.rb",
     "test/rpm_test.rb",
     "test/running_build_test.rb",
     "test/template_set_test.rb"
  ]
  s.homepage = %q{http://github.com/jreidinger/studio_api}
  s.rdoc_options = ["--line-numbers", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Studio Api Interface.}
  s.test_files = [
    "test/resource_test.rb",
     "test/template_set_test.rb",
     "test/build_test.rb",
     "test/appliance_test.rb",
     "test/file_test.rb",
     "test/connection_test.rb",
     "test/generic_request_test.rb",
     "test/repository_test.rb",
     "test/running_build_test.rb",
     "test/rpm_test.rb",
     "test/responses/builds.xml",
     "test/responses/software_installed.xml",
     "test/responses/running_build.xml",
     "test/responses/file.xml",
     "test/responses/files.xml",
     "test/responses/appliance.xml",
     "test/responses/gpg_key.xml",
     "test/responses/status.xml",
     "test/responses/gpg_keys.xml",
     "test/responses/appliances.xml",
     "test/responses/software_search.xml",
     "test/responses/repository.xml",
     "test/responses/rpm.xml",
     "test/responses/rpms.xml",
     "test/responses/repositories.xml",
     "test/responses/running_builds.xml",
     "test/responses/software.xml",
     "test/responses/build.xml",
     "test/responses/template_sets.xml"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activeresource>, [">= 1.3.8"])
      s.add_runtime_dependency(%q<xml-simple>, [">= 1.0.0"])
    else
      s.add_dependency(%q<activeresource>, [">= 1.3.8"])
      s.add_dependency(%q<xml-simple>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<activeresource>, [">= 1.3.8"])
    s.add_dependency(%q<xml-simple>, [">= 1.0.0"])
  end
end

