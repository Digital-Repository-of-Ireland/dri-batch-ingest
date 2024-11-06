# frozen_string_literal: true
require 'underscore-rails'
require 'jstree-rails-4'
require 'browse_everything'

module DRIBatchIngest
  class Engine < ::Rails::Engine
    isolate_namespace DRIBatchIngest

    config.generators do |g|
      g.test_framework :rspec
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end
