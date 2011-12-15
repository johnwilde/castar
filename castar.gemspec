# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "castar/version"

Gem::Specification.new do |s|
  s.name        = "castar"
  s.version     = Castar::VERSION
  s.authors     = ["John Wilde"]
  s.email       = ["johnwilde@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Ruby interface to a C++ implementation of the A* algorithm}
  s.description = File.read(File.join(File.dirname(__FILE__), 'README.markdown'))

  s.rubyforge_project = "castar"

  s.files         = `git ls-files`.split("\n")
  s.extensions    = ["ext/extconf.rb"]
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib","ext"]

  # specify any dependencies here; for example:
  # s.add_runtime_dependency "rest-client"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-core"
end
