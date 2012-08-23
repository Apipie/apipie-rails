module Apipie
  module Extractor
    class Collector
      attr_reader :descriptions, :records

      def initialize
        @api_controllers_paths = Apipie.api_controllers_paths
        @ignored = Apipie.configuration.ignored_by_recorder
        @descriptions = Hash.new do |h, k|
          h[k] = {:params => {}, :errors => Set.new}
        end
        @records = Hash.new { |h,k| h[k] = [] }
      end

      def controller_full_path(controller)
        File.join(Rails.root, "app", "controllers", "#{controller.controller_path}_controller.rb")
      end

      def ignore_call?(record)
        return true unless record[:controller]
        return true if @ignored.include?(record[:controller].name)
        return true if @ignored.include?("#{record[:controller].name}##{record[:action]}")
        return true unless @api_controllers_paths.include?(controller_full_path(record[:controller]))
      end

      def handle_record(record)
        add_to_records(record)
        if ignore_call?(record)
          Extractor.logger.info("REST_API: skipping #{record_to_s(record)}")
        else
          refine_description(record)
        end
      end

      def add_to_records(record)
        key = "#{record[:controller].controller_name}##{record[:action]}"
        @records[key] << record
      end

      def refine_description(record)
        description = @descriptions["#{record[:controller].name}##{record[:action]}"]
        description[:controller] ||= record[:controller]
        description[:action] ||= record[:action]

        refine_errors_description(description, record)
        refine_params_description(description[:params], record[:params])
      end

      def refine_errors_description(description, record)
        if record[:code].to_i >= 300 && !description[:errors].any? { |e| e[:code].to_i == record[:code].to_i }
          description[:errors] << {:code => record[:code]}
        end
      end

      def refine_params_description(params_desc, recorded_params)
        recorded_params.each do |key, value|
          params_desc[key] ||= {}
          param_desc = params_desc[key]

          if value.nil?
            param_desc[:allow_nil] = true
          else
            # we specify what type it might be. At the end the first type
            # that left is taken as the more general one
            unless param_desc[:type]
              param_desc[:type] = [:bool, :number]
              param_desc[:type] << Hash if value.is_a? Hash
              param_desc[:type] << :undef
            end

            if param_desc[:type].first == :bool && (! [true, false].include?(value))
              param_desc[:type].shift
            end

            if param_desc[:type].first == :number && (key.to_s !~ /id$/ || !Apipie::Validator::NumberValidator.validate(value))
              param_desc[:type].shift
            end
          end

          if value.is_a? Hash
            param_desc[:nested] ||= {}
            refine_params_description(param_desc[:nested], value)
          end
        end
      end

      def finalize_descriptions
        @descriptions.each do |method, desc|
          add_routes_info(desc)
        end
        return @descriptions
      end

      def add_routes_info(desc)
        api_prefix = Apipie.api_base_url.sub(/\/$/,"")
        desc[:api] = Apipie::Extractor.apis_from_routes[[desc[:controller].name, desc[:action]]]
        if desc[:api]
          desc[:params].each do |name, param|
            if desc[:api].all? { |a| a[:path].include?(":#{name}") }
              param[:required] = true
            end
          end
        end
      end

      def record_to_s(record)
        "#{record[:controller]}##{record[:action]}"
      end

    end
  end
end

