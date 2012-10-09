require 'rest_client'
require 'oauth'
require 'json'
require 'apipie/client/rest_client_oauth'

module Apipie
  module Client

    class Base
      attr_reader :client, :config

      def initialize(config, options = { })
        @client = RestClient::Resource.new config[:base_url],
                                           :user     => config[:username],
                                           :password => config[:password],
                                           :oauth    => config[:oauth],
                                           :headers  => { :content_type => 'application/json',
                                                          :accept       => 'application/json' }
        @config = config
      end

      def call(method, path, params = { }, headers = { })
        headers ||= { }

        args = [method]
        if [:post, :put].include?(method)
          args << params.to_json
        else
          headers[:params] = params if params
        end

        args << headers if headers
        process_data client[path].send(*args)
      end

      def self.doc
        raise NotImplementedError
      end

      def self.validation_hash(method)
        validation_hashes[method.to_s]
      end

      def self.method_doc(method)
        method_docs[method.to_s]
      end

      def validate_params!(params, rules)
        return unless params.is_a?(Hash)

        invalid_keys = params.keys.map(&:to_s) - (rules.is_a?(Hash) ? rules.keys : rules)
        raise ArgumentError, "Invalid keys: #{invalid_keys.join(", ")}" unless invalid_keys.empty?

        if rules.is_a? Hash
          rules.each do |key, sub_keys|
            validate_params!(params[key], sub_keys) if params[key]
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

      def check_params(params, options = { })
        raise ArgumentError unless (method = options[:method])
        return unless config[:enable_validations]

        case options[:allowed]
          when true
            validate_params!(params, self.class.validation_hash(method))
          when false
            raise ArgumentError, "this method '#{method}' does not support params" if params && !params.empty?
          else
            raise ArgumentError, "options :allowed should be true or false, it was #{options[:allowed]}"
        end
      end

      # @return url and rest of the params
      def fill_params_in_url(url, params)
        params          ||= { }
        # insert param values
        url_param_names = params_in_path(url)
        url             = params_in_path(url).inject(url) do |url, param_name|
          param_value = params[param_name] or
              raise ArgumentError, "missing param '#{param_name}' in parameters"
          url.sub(":#{param_name}", param_value.to_s)
        end

        return url, params.reject { |param_name, _| url_param_names.include? param_name }
      end

      private

      def self.method_docs
        @method_docs ||= doc['methods'].inject({ }) do |hash, method|
          hash[method['name']] = method
          hash
        end
      end

      def self.validation_hashes
        @validation_hashes ||= method_docs.inject({ }) do |hash, pair|
          name, method_doc = pair
          hash[name]       = construct_validation_hash method_doc
          hash
        end
      end

      def self.construct_validation_hash(method)
        if method['params'].any? { |p| p['params'] }
          method['params'].reduce({ }) do |h, p|
            h.update(p['name'] => (p['params'] ? p['params'].map { |pp| pp['name'] } : nil))
          end
        else
          method['params'].map { |p| p['name'] }
        end
      end

      def params_in_path(url)
        url.scan(/:([^\/]*)/).map { |m| m.first }
      end

    end
  end
end
