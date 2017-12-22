require 'singleton'
require 'fileutils'
require 'set'
require 'yaml'
require 'apipie/extractor/recorder'
require 'apipie/extractor/writer'
require 'apipie/extractor/collector'

class Apipie::Railtie
  initializer 'apipie.extractor' do |app|
    ActiveSupport.on_load :action_controller do
      before_action do |controller|
        if Apipie.configuration.record
          Apipie::Extractor.call_recorder.analyse_controller(controller)
        end
      end
    end
    app.middleware.use ::Apipie::Extractor::Recorder::Middleware
    ActionController::TestCase::Behavior.instance_eval do
      prepend Apipie::Extractor::Recorder::FunctionalTestRecording
    end
  end
end

module Apipie

  module Extractor

    class << self

      def start(record)
        Apipie.configuration.record = record
        Apipie.configuration.force_dsl = true
      end

      def finish
        record_params, record_examples = false, false
        case ENV['APIPIE_RECORD']
        when "params"   then record_params = true
        when "examples" then record_examples = true
        when "all"      then record_params = true, record_examples = true
        end

        if record_examples
          puts "Writing examples to a file"
          write_examples
        end
        if record_params
          puts "Updating auto-generated documentation"
          write_docs
        end
      end

      def logger
        Rails.logger
      end

      def call_recorder
        Thread.current[:apipie_call_recorder] ||= Recorder.new
      end

      def call_finished
        @collector ||= Collector.new
        if record = call_recorder.record
          @collector.handle_record(record)
        end
      end

      def clean_call_recorder
        Thread.current[:apipie_call_recorder] = nil
      end

      def write_docs
        Writer.new(@collector).write_docs if @collector
      end

      def write_examples
        Writer.new(@collector).write_examples if @collector
      end

      def apis_from_routes
        return @apis_from_routes if @apis_from_routes

        @api_prefix = Apipie.api_base_url.sub(/\/$/,"")
        populate_api_routes
        update_api_descriptions

        @apis_from_routes
      end

      def controller_path(name)
        Apipie.api_controllers_paths.detect { |p| p.include?("#{name}_controller.rb") }
      end

      private

      def all_api_routes
        all_routes = Apipie.configuration.api_routes.routes.map do |r|
          {
              :verb => case r.verb
                         when Regexp then r.verb.source[/\w+/]
                         else r.verb.to_s
                       end,
              :path => case
                         when r.path.respond_to?(:spec) then r.path.spec.to_s
                         else r.path.to_s
                       end,
              :controller => r.requirements[:controller],
              :action => r.requirements[:action]
          }
        end

        return all_routes.find_all do |r|
          r[:path].starts_with?(Apipie.api_base_url)
        end
      end

      def populate_api_routes
        @apis_from_routes = Hash.new { |h, k| h[k] = [] }

        all_api_routes.each do |route|
          controller_path, action = route[:controller], route[:action]
          next unless controller_path && action

          controller_path = controller_path.split('::').map(&:camelize).join('::')
          controller = "#{controller_path}Controller"

          path = if /^#{Regexp.escape(@api_prefix)}(.*)$/ =~ route[:path]
                   $1.sub(/\(\.:format\)$/,'')
                 else
                   nil
                 end

          if route[:verb].present?
            @apis_from_routes[[controller, action]] << {:method => route[:verb], :path => path}
          end
        end
      end

      def all_apis_from_docs
        resource_descriptions = Apipie.resource_descriptions.values.map(&:values).flatten
        method_descriptions = resource_descriptions.map(&:method_descriptions).flatten

        return method_descriptions.reduce({}) do |h, desc|
          apis = desc.method_apis_to_json.map do |api|
            { :method => api[:http_method],
              :path => api[:api_url],
              :desc => api[:short_description] }
          end
          h.update(desc.id => apis)
        end
      end

      def update_api_descriptions
        apis_from_docs = all_apis_from_docs
        @apis_from_routes.each do |(controller, action), new_apis|
          method_key = "#{Apipie.get_resource_name(controller.safe_constantize || next)}##{action}"
          old_apis = apis_from_docs[method_key] || []
          new_apis.each do |new_api|
            new_api[:path].sub!(/\(\.:format\)$/,"") if new_api[:path]
            old_api = old_apis.find do |api|
              api[:path] == "#{@api_prefix}#{new_api[:path]}"
            end
            if old_api
              new_api[:desc] = old_api[:desc]
            end
          end
        end
      end
    end
  end
end

if ENV["APIPIE_RECORD"]
  Apipie::Extractor.start ENV["APIPIE_RECORD"]
end

at_exit do
  Apipie::Extractor.finish
end
