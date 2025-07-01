# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "dri_batch_ingest/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dri_batch_ingest"
  s.version     = DRIBatchIngest::VERSION
  s.authors     = ["Stuart Kenny"]
  s.email       = ["skenny@tchpc.tcd.ie"]
  s.homepage    = "https://github.com/Digital-Repository-of-Ireland/dri_batch_ingest"
  s.summary     = "Batch ingest functionality for the DRI application"
  s.description = "Batch ingest functionality for the DRI application"
  s.license     = "Apache-2.0"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency 'rails', '> 6', '< 8'
  s.add_dependency 'kaminari'
  s.add_dependency 'underscore-rails'
  s.add_dependency 'iconv'
  s.add_dependency 'filesize'
  s.add_dependency 'resque'
  s.add_dependency 'rest-client', '~> 2.0'
  s.add_dependency 'roo'
  s.add_dependency 'browse-everything', '~> 1.0'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'bixby'
end
