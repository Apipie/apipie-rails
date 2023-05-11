module Apipie
  module Extractor
    class Recorder
      MULTIPART_BOUNDARY = 'APIPIE_RECORDER_EXAMPLE_BOUNDARY'

      def initialize
        @ignored_params = [:controller, :action]
      end

      def analyse_env(env)
        @verb = env["REQUEST_METHOD"].to_sym
        @path = env["PATH_INFO"].sub(/^\/*/,"/")
        @query = env["QUERY_STRING"] unless env["QUERY_STRING"].blank?
        @params = Rack::Utils.parse_nested_query(@query)
        @params.merge!(env["action_dispatch.request.request_parameters"] || {})
        rack_input = env["rack.input"]
        if data = parse_data(rack_input.read)
          @request_data = data
        elsif form_hash = env["rack.request.form_hash"]
          @request_data = reformat_multipart_data(form_hash)
        end
        rack_input.rewind
      end

      def analyse_controller(controller)
        @controller = controller.class
        @action = controller.params[:action]
      end

      def analyse_response(response)
        if response.last.respond_to?(:body) && data = parse_data(response.last.body)
          @response_data = if response[1]['Content-Disposition'].to_s.start_with?('attachment')
                             '<STREAMED ATTACHMENT FILE>'
                           else
                             data
                           end
        end
        @code = response.first
      end

      def analyze_functional_test(test_context)
        request, response = test_context.request, test_context.response
        @verb = request.request_method.to_sym
        @path = request.path
        @params = request.request_parameters
        if [:POST, :PUT, :PATCH, :DELETE].include?(@verb)
          @request_data = @params
        else
          @query = request.query_string
        end
        if response.content_type != 'application/pdf'
          @response_data = parse_data(response.body)
        end
        @code = response.code
      end

      def parse_data(data)
        return nil if data.strip.blank?
        JSON.parse(data)
      rescue StandardError
        data
      end

      def reformat_multipart_data(form)
        form.empty? and return ''
        lines = ["Content-Type: multipart/form-data; boundary=#{MULTIPART_BOUNDARY}",'']
        boundary = "--#{MULTIPART_BOUNDARY}"
        form.each do |key, attrs|
          if attrs.is_a?(String)
            lines << boundary << content_disposition(key) << "Content-Length: #{attrs.size}" << '' << attrs
          else
            reformat_hash(boundary, attrs, lines)
          end
        end
        lines << "#{boundary}--"
        lines.join("\n")
      end

      def reformat_hash(boundary, attrs, lines)
        if head = attrs[:head]
          lines << boundary
          lines.concat(head.split("\r\n"))
          # To avoid large and/or binary file bodies, simply indicate the contents in the output.
          lines << '' << %{... contents of "#{attrs[:name]}" ...}
        else
          # Look for subelements that contain a part.
          attrs.each { |k,v| v.is_a?(Hash) and reformat_hash(boundary, v, lines) }
        end
      end

      def content_disposition(name)
        %{Content-Disposition: form-data; name="#{name}"}
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
          if Apipie.configuration.record
            analyze(env) do
              @app.call(env)
            end
          else
            @app.call(env)
          end
        end

        def analyze(env, &block)
          Apipie::Extractor.call_recorder.analyse_env(env)
          response = block.call
          Apipie::Extractor.call_recorder.analyse_response(response)
          Apipie::Extractor.call_finished
          response
        ensure
          Apipie::Extractor.clean_call_recorder
        end
      end

      module FunctionalTestRecording
        def process(*args) # action, parameters = nil, session = nil, flash = nil, http_method = 'GET')
          ret = super(*args)
          if Apipie.configuration.record
            Apipie::Extractor.call_recorder.analyze_functional_test(self)
            Apipie::Extractor.call_finished
          end
          ret
        ensure
          Apipie::Extractor.clean_call_recorder
        end
      end
    end
  end
end
