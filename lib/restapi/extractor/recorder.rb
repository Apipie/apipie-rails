module Restapi
  module Extractor
    class Recorder
      def initialize
        @ignored_params = [:controller, :action]
      end

      def analyse_env(env)
        @verb = env["REQUEST_METHOD"].to_sym
        @path = env["PATH_INFO"].sub(/^\/*/,"/")
        @query = env["QUERY_STRING"] unless env["QUERY_STRING"].blank?
        @params = Rack::Utils.parse_nested_query(@query)
        @params.merge!(env["action_dispatch.request.request_parameters"] || {})
        if data = parse_data(env["rack.input"].read)
          @request_data = data
        end
      end

      def analyse_controller(controller)
        @controller = controller.class
        @action = controller.params[:action]
      end

      def analyse_response(response)
        if response.last.respond_to?(:body) && data = parse_data(response.last.body)
          @response_data = data
        end
        @code = response.first
      end

      def parse_data(data)
        return nil if data.to_s =~ /^\s*$/
        JSON.parse(data)
      rescue Exception => e
        data
      end

      def reformat_data(data)
        parsed = parse_data(data)
        case parsed
        when nil
          nil
        when String
          parsed
        else
          JSON.pretty_generate().gsub(/: \[\s*\]/,": []").gsub(/\{\s*\}/,"{}")
        end
      end

      def record
        if @controller
          {:controller => @controller,
           :action => @action,
           :verb => @verb,
           :path => @path,
           :params => @params,
           :query => @query,
           :request_data => @request_data,
           :response_data => @response_data,
           :code => @code}
        else
          nil
        end
      end

      protected

      def api_description
      end

      class Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          analyze(env) do
            @app.call(env)
          end
        end

        def analyze(env, &block)
          Restapi::Extractor.call_recorder.analyse_env(env)
          response = block.call
          Restapi::Extractor.call_recorder.analyse_response(response)
          response
        ensure
          Restapi::Extractor.call_finished
        end
      end

    end

  end
end
