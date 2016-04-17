require 'rails/railtie'

module Immigrate
  class Railtie < Rails::Railtie
    initializer 'immigrate.load' do
      ActiveSupport.on_load :active_record do
        Immigrate.load
      end
    end
  end
end
