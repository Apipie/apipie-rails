module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

    module Common
      def api_versions(*versions)
        _apipie_dsl_data[:api_versions].concat(versions)
      end
      alias :api_version :api_versions

      # Describe the next method.
      #
      # Example:
      #   desc "print hello world"
      #   def hello_world
      #     puts "hello world"
      #   end
      #
      def desc(description) #:doc:
        return unless Apipie.active_dsl?
        if _apipie_dsl_data[:description]
          raise "Double method description."
        end
        _apipie_dsl_data[:description] = description
      end
      alias :description :desc
      alias :full_description :desc

      # describe next method with document in given path
      # in convension, these doc located under "#{Rails.root}/doc"
      # Example:
      # document "hello_world.md"
      # def hello_world
      #   puts "hello world"
      # end
      def document path
        content = File.open(File.join(Rails.root,  Apipie.configuration.doc_path, path)).read
        desc content
      end

      # Describe available request/response formats
      #
      #   formats ['json', 'jsonp', 'xml']
      def formats(formats) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:formats] = formats
      end

      # Describe additional metadata
      #
      #   meta :author => { :name => 'John', :surname => 'Doe' }
      def meta(meta) #:doc:
        _apipie_dsl_data[:meta] = meta
      end


      # Describe possible responses
      #
      # Example:
      #   response :desc => "speaker is sleeping", :code => 500, :meta => [:some, :more, :data]
      #   response 500, "speaker is sleeping"
      #   def hello_world
      #     return 500 if self.speaker.sleeping?
      #     puts "hello world"
      #   end
      #
      def response(code_or_options, desc=nil, options={}) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:responses] << [code_or_options, desc, options]
      end

      def error(code_or_options, desc=nil, options={})
        response(code_or_options, desc, options)
      end

      def success(code_or_options, desc=nil, options={})
        response(code_or_options, desc, options)
      end

      def _apipie_define_validators(description)

        # [re]define method only if validation is turned on
        if description && (Apipie.configuration.validate == true ||
                           Apipie.configuration.validate == :implicitly ||
                           Apipie.configuration.validate == :explicitly)

          _apipie_save_method_params(description.method, description.params)

          unless instance_methods.include?(:apipie_validations)
            define_method(:apipie_validations) do
              method_params = self.class._apipie_get_method_params(action_name)

              if Apipie.configuration.validate_presence?
                method_params.each do |_, param|
                  # check if required parameters are present
                  raise ParamMissing.new(param) if param.required && !params.has_key?(param.name)
                end
              end

              if Apipie.configuration.validate_value?
                method_params.each do |_, param|
                  # params validations
                  param.validate(params[:"#{param.name}"]) if params.has_key?(param.name)
                end
              end

              # Only allow params passed in that are defined keys in the api
              # Auto skip the default params (format, controller, action)
              if Apipie.configuration.validate_key?
                params.reject{|k,_| %w[format controller action].include?(k.to_s) }.each_key do |param|
                  # params allowed
                  raise UnknownParam.new(param) if method_params.select {|_,p| p.name.to_s == param.to_s}.empty?
                end
              end

              if Apipie.configuration.process_value?
                @api_params ||= {}
                method_params.each do |_, param|
                  # params processing
                  @api_params[param.as] = param.process_value(params[:"#{param.name}"]) if params.has_key?(param.name)
                end
              end
            end
          end

          if (Apipie.configuration.validate == :implicitly || Apipie.configuration.validate == true)
            old_method = instance_method(description.method)

            define_method(description.method) do |*args|
              apipie_validations

              # run the original method code
              old_method.bind(self).call(*args)
            end
          end

        end
      end

      def _apipie_save_method_params(method, params)
        @method_params ||= {}
        @method_params[method] = params
      end

      def _apipie_get_method_params(method)
        @method_params[method]
      end

      # Describe request header.
      #  Headers can't be validated with config.validate_presence = true
      #
      # Example:
      #   header 'ClientId', "client-id"
      #   def show
      #     render :text => headers['HTTP_CLIENT_ID']
      #   end
      #
      def header(header_name, description, options = {}) #:doc
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:headers] << {
          name: header_name,
          description: description,
          options: options
        }
      end
    end

  end # module DSL
end # module Apipie
