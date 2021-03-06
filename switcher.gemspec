# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "switcher/version"

Gem::Specification.new do |s|
  s.name        = "switcher"
  s.version     = Switcher::VERSION
  s.authors     = ["Andrey Savchenko"]
  s.email       = ["andrey@aejis.eu"]
  s.homepage    = "https://github.com/Ptico/switcher"
  s.summary     = %q{Switcher is simple, event-driven state machine}
  s.description = %q{Switcher is simple, event-driven state machine}

  s.rubyforge_project = "switcher"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  #s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
