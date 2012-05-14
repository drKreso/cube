# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "cube/version"

Gem::Specification.new do |gem|
  gem.authors       = ["drKreso", "stellard"]
  gem.email         = ["kresimir.bojcic@gmail.com", "scott@kujilabs.com"]
  gem.description = "Eases the pain I had to go through to get to the data out of XMLA based OLAP provider(Mondiran, Pentaho, icCube)"
  gem.summary = "Get's the data from OLAP cube via XMLA(Mondiran, Pentaho, icCube)"
  gem.homepage = "http://github.com/kujilabs/cube"
  gem.date = "2012-05-13"


  gem.licenses = ["MIT"]
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "cube"
  gem.require_paths = ["lib"]
  gem.version = Cube::VERSION


  gem.add_dependency "savon", ">= 0"
  gem.add_dependency "webmock", ">= 0"
  gem.add_dependency "guerrilla_patch", ">= 0"
end

