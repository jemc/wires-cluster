Gem::Specification.new do |s|
  s.name          = 'wires-cluster'
  s.version       = '0.0.1'
  s.date          = '2013-09-03'
  s.summary       = "wires-cluster"
  s.description   = "Wires extension gem for firing and receiving events "\
                    "between Ruby processes with UDP multicasts."
  s.authors       = ["Joe McIlvain"]
  s.email         = 'joe.eli.mac@gmail.com'
  s.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path  = 'lib'
  s.homepage      = 'https://github.com/jemc/wires-cluster/'
  s.licenses      = "Copyright (c) Joe McIlvain. All rights reserved "
  
  s.add_dependency('wires')
  s.add_dependency('json')
  
  s.add_development_dependency('rake')
  s.add_development_dependency('wires-test')
  s.add_development_dependency('jemc-reporter')
end