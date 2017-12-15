module DRI::BatchIngest
  class Engine < ::Rails::Engine
    isolate_namespace DRI::BatchIngest

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
