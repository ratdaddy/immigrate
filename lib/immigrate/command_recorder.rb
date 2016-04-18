module Immigrate
  module CommandRecorder
    def create_foreign_connection *args
      record(:create_foreign_connection, args)
    end

    def invert_create_foreign_connection *args
      [:drop_foreign_connection, *args]
    end
  end
end
