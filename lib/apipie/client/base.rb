require 'rest_client'
require 'oauth'
require 'json'
require 'apipie/client/rest_client_oauth'

module Apipie::Client

    class Base
      attr_reader :client

      def initialize(config, options = { })
      @client = RestClient::Resource.new config[:base_url],
                                         :user     => config[:username],
                                         :password => config[:password],
                                         :oauth    => config[:oauth],
                                         :headers  => { :content_type => 'application/json',
                                                        :accept       => 'application/json' }
      end

      def call(method, path, options = { })
        payload, headers, params = options.values_at :payload, :headers, :params
        headers[:params] = params if params

        args = [method]
        args << payload.to_json if [:post, :put].include?(method)
        args << headers if headers
        process_data client[path].send(*args)
      end

      def validate_params!(options, valid_keys)
        return unless options.is_a?(Hash)
        invalid_keys = options.keys.map(&:to_s) - (valid_keys.is_a?(Hash) ? valid_keys.keys : valid_keys)
        raise ArgumentError, "Invalid keys: #{invalid_keys.join(", ")}" unless invalid_keys.empty?

        if valid_keys.is_a? Hash
          valid_keys.each do |key, keys|
            if options[key]
              validate_params!(options[key], keys)
            end
          end
        end
      end

      protected

      def process_data(response)
        data = begin
          JSON.parse(response.body)
        rescue JSON::ParserError
          response.body
        end
        return data, response
      end

    end
end
