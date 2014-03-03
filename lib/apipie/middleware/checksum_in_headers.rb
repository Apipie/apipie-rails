# Middleware for rails app that adds checksum of JSON in the response headers
# which can help client to realize when JSON has changed
#
# Add the following to your application.rb
#   require 'apipie/middleware/checksum_in_headers'
#   # Add JSON checksum in headers for smarter caching
#   config.middleware.use "Apipie::Middleware::ChecksumInHeaders"
#
# And in your apipie initializer allow checksum calculation
#   Apipie.configuration.update_checksum = true
# and reload documentation
#   Apipie.reload_documentation
#
# By default the header is added to requests on /api and /apipie only
# It can be changed with
#   Apipie.configuration.checksum_path = ['/prefix/api']
# If set to nil the header is added always

module Apipie
  module Middleware
    class ChecksumInHeaders
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        if !Apipie.configuration.checksum_path || env['PATH_INFO'].start_with?(*Apipie.configuration.checksum_path)
          headers.merge!( 'Apipie-Checksum' => Apipie.checksum )
        end
        return [status, headers, body]
      end
    end
  end
end
