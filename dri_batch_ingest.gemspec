lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "dri/batch_ingest/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dri_batch_ingest"
  s.version     = DRI::BatchIngest::VERSION
  s.authors     = ["Stuart Kenny"]
  s.email       = ["skenny@tchpc.tcd.ie"]
  s.homepage    = "https://github.com/Digital-Repository-of-Ireland/dri_batch_ingest"
  s.summary     = "Batch ingest functionality for the DRI application"
  s.description = "Batch ingest functionality for the DRI application"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.10"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
end
