$:.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'test_engine'
  s.version     = '0.0.1'
  s.summary     = 'Test Engine'
  s.authors     = 'Test Author'

  s.files = Dir['{app,config,db,lib}/**/*']
end
