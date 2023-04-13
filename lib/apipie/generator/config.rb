module Apipie
  module Generator
    # Configuration interface for generators
    class Config
      include Singleton

      def swagger
        Apipie::Generator::Swagger::Config.instance
      end
    end
  end
end
