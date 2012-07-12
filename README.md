Studio API: Wrapper to STUDIO API
=================================

Synopsis
--------

Studio API library is intended to easier access to Studio API from ruby,
but keep it easily extensible and easy maintanable, so it not need rewritting
when new attributes introduced to Studio. It leads also that user need to know 
API documentation, which specify what options you need to use (see http://susestudio.com/help/api/v1 ).
It has also feature which allows using in multiuser system (like server).

Example
-------

Example usage ( more in class documentation ). Example show how to clone appliance,
upload own rpm, select it, find new software and add it, run new build and then print information about appliance.
Note: All error handling is for simplicity removed. It is same as for ActiveResource so if you want see him, search
for ActiveResource error handling.

```ruby
require 'rubygems'
# If you want use it from git adapt LOAD_PATH
# you can load just required parts if you need, but Util loaded all classes to properly set it
require 'studio_api'

# Fill up Studio credentials (user name, API key, API URL)
# See https://susestudio.com/user/show_api_key if you are using SUSE Studio online
connection = StudioApi::Connection.new('user', 'pwd', 'https://susestudio.com/api/v1/user')
# Setup the connection for all ActiveResource based class
StudioApi::Util.configure_studio_connection connection

# Find template with KDE4 for SLE11SP1
templates = StudioApi::TemplateSet.find(:all).find {|s| s.name == "default" }.template
template = templates.find { |t| t.name == "SLED 11 SP1, KDE 4 desktop" }
# clone template to new appliance
appliance = StudioApi::Appliance.clone template.appliance_id, :name => "New cool appliance", :arch => "i686" 
puts "Created appliance #{appliance.inspect}"

#add own rpm built agains SLED11_SP1
File.open("/home/jreidinger/rpms/kezboard-1.0-1.60.noarch.rpm") do |file|
  StudioApi::Rpm.upload file, "SLED11_SP1"
end
# and choose it in appliance ( and of course add repository with own rpms)
appliance.add_user_repository
appliance.add_package "kezboard", :version => "1.0-1.60"

# find samba package and if it is not found in repositories in appliance, try it in all repos
result = appliance.search_software("samba").find { |s| s.name == "samba" }
unless result #it is not found in available repos
  result = appliance.search_software("samba", :all_repos => "true").find { |s| s.name == "samba" }
  # add repo which contain samba
  appliance.add_repository result.repository_id
end
appliance.add_package "samba"

#check if appliance is OK
if appliance.status.state != "ok"
  raise "appliance is not OK - #{appliance.status.issues.inspect}"
end
debugger
build = StudioApi::RunningBuild.new(:appliance_id => appliance.id, :image_type => "xen")
build.save
build.reload
while build.state != "finished"
  puts "building (#{build.state}) - #{build.percent}%"
  sleep 5
  build.reload
end

final_build = StudioApi::Build.find build.id
puts final_build.inspect

# to clear after playing with appliance if you keep same name, clean remove appliances with:
# appliances = StudioApi::Appliance.find :all
# appliances.select{ |a| a.name =~ /cool/i }.each{ |a| a.destroy }
```

Second example contain how to easy mock calling studio stuff without mock server. Using mocha

```ruby
require 'mocha'
require 'studio_api'

APPLIANCE_UUID = "68c91080-ccca-4270-a1d3-10e714ddd1c6"
APPLIANCE_VERSION = "0.0.1"
APPLIANCE_STUDIO_ID = "97216"
BUILD_ID = "180420"
APPLIANCE_1 = StudioApi::Appliance.new :id => APPLIANCE_STUDIO_ID, :name => "Test", :arch => 'i386',
                          :last_edited => "2010-10-08 14:46:07 UTC", :estimated_raw_size => "390 MB", :estimated_compressed_size => "140 MB",
                          :edit_url => "http://susestudio.com/appliance/edit/266657", :icon_url => "http://susestudio.com/api/v1/user/appliance_icon/266657",
                          :basesystem => "SLES11_SP1", :uuid => APPLIANCE_UUID, :parent => {:id => "202443", :name => "SLES 11 SP1, Just enough OS (JeOS)"},
                          :builds => [{:id =>BUILD_ID,:version => APPLIANCE_VERSION, :image_type => "vmx", :image_size => "695",
                          :compressed_image_size => "121",
                          :download_url => "http://susestudio.com/download/a0f0217f0645099c9e41c42e9bf89976/josefs_SLES_11_SP1_git_test.i686-0.0.1.vmx.tar.gz"}] 
  
#real mocking
StudioApi::Appliance.stubs(:find).with(APPLIANCE_STUDIO_ID).returns(APPLIANCE_1)
```
