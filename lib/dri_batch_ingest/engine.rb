require 'underscore-rails'
require 'fuelux-rails-sass'
require 'browse_everything'

module DriBatchIngest
  class Engine < ::Rails::Engine
    isolate_namespace DriBatchIngest

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
