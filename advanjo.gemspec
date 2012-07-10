# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "advanjo/version"

Gem::Specification.new do |s|
  s.name        = "advanjo"
  s.version     = Advanjo::VERSION
  s.authors     = ["Pavel Manylov"]
  s.email       = ["rapkasta@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Advanced Joins in your ActiveRecord 3 apps}
  s.description = %q{Add complex joins to your query, using Arel notation. Use subqueries as join sources and select fields you want from it.}

  s.rubyforge_project = "advanjo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('activerecord', '>= 3.0', '< 4.0')
  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
