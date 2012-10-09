module Apipie
  module Client
    class Thor < ::Thor

      def self.apipie_options
        Apipie::Client::Thor.instance_variable_get :@apipie_options
      end

      no_tasks do
        def apipie_options
          self.class.apipie_options
        end
      end

      def self.apipie_options=(options)
        Apipie::Client::Thor.instance_variable_set :@apipie_options, options
      end

    end
  end
end
