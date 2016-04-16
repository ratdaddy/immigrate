require File.expand_path('../boot', __FILE__)

require 'active_record/railtie'

Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.cache_classes = true
    config.eager_load = false
    config.active_support.deprecation = :stderr
  end
end
