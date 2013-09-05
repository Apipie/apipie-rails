require 'set'

module Apipie
  module Extractor
    class Writer

      def initialize(collector)
        @collector = collector
        @examples_file = File.join(Rails.root, "doc", "apipie_examples.yml")
      end

      def write_examples
        merged_examples = merge_old_new_examples
        FileUtils.mkdir_p(File.dirname(@examples_file))
        File.open(@examples_file, "w") do |f|
          f << YAML.dump(OrderedHash[*merged_examples.sort_by(&:first).flatten(1)])
        end
      end

      def write_docs
        descriptions = @collector.finalize_descriptions
        descriptions.each do |_, desc|
          if desc[:api].empty?
            logger.warn("REST_API: Couldn't find any path for #{desc_to_s(desc)}")
            next
          end
          self.class.update_action_description(desc[:controller], desc[:action]) do |u|
            u.update_generated_description desc
          end
        end
      end

      def self.update_action_description(controller, action)
        updater = ActionDescriptionUpdater.new(controller, action)
        yield updater
        updater.write!
      rescue ActionDescriptionUpdater::ControllerNotFound
        logger.warn("REST_API: Couldn't find controller file for #{controller}")
      rescue ActionDescriptionUpdater::ActionNotFound
        logger.warn("REST_API: Couldn't find action #{action} in #{controller}")
      end

      protected

      def desc_to_s(description)
        "#{description[:controller].name}##{description[:action]}"
      end

      def ordered_call(call)
        call = call.stringify_keys
        ordered_call = OrderedHash.new
        %w[verb path versions query request_data response_data code show_in_doc recorded].each do |k|
          next unless call.has_key?(k)
          ordered_call[k] = case call[k]
                       when ActiveSupport::HashWithIndifferentAccess
                         JSON.parse(call[k].to_json) # to_hash doesn't work recursively and I'm too lazy to write the recursion:)
                       else
                         call[k]
                       end
        end
        return ordered_call
      end

      def merge_old_new_examples
        new_examples = self.load_new_examples
        old_examples = self.load_old_examples
        merged_examples = []
        (new_examples.keys + old_examples.keys).uniq.each do |key|
          if new_examples.has_key?(key)
            records = new_examples[key]
          else
            records = old_examples[key]
          end
          merged_examples << [key, records.map { |r|  ordered_call(r) } ]
        end
        return merged_examples
      end

      def load_new_examples
        @collector.records.reduce({}) do |h, (method, calls)|
          showed_in_versions = Set.new
          # we have already shown some example
          recorded_examples = calls.map do |call|
            method_descriptions = Apipie.get_method_descriptions(call[:controller], call[:action])
            call[:versions] = method_descriptions.map(&:version)

            if call[:versions].any? { |v| ! showed_in_versions.include?(v) }
              call[:versions].each { |v| showed_in_versions << v }
              show_in_doc = 1
            else
              show_in_doc = 0
            end
            example = call.merge(:show_in_doc => show_in_doc.to_i, :recorded => true)
            example
          end
          h.update(method => recorded_examples)
        end
      end

      def load_old_examples
        if File.exists?(@examples_file)
           if defined? SafeYAML
              return YAML.load_file(@examples_file, :safe=>false)
            else
              return YAML.load_file(@examples_file)
            end
        end
        return {}
      end

      def logger
        self.class.logger
      end

      def self.logger
        Extractor.logger
      end

      def showable_in_doc?(call)
        # we don't want to mess documentation with too large examples
        if hash_nodes_count(call["request_data"]) + hash_nodes_count(call["response_data"]) > 100
          return false
        else
          return 1
        end
      end

      def hash_nodes_count(node)
        case node
        when Hash
          1 + (node.values.map { |v| hash_nodes_count(v) }.reduce(:+) || 0)
        when Array
          node.map { |v| hash_nodes_count(v) }.reduce(:+) || 1
        else
          1
        end
      end

    end

    class ActionDescriptionUpdater

      class ControllerNotFound < StandardError; end

      class ActionNotFound < StandardError; end

      def initialize(controller, action)
        @controller = controller
        @action = action
      end

      def generated?
        old_header.include?(Apipie.configuration.generated_doc_disclaimer)
      end

      def update_apis(apis)
        new_header = ""
        new_header << Apipie.configuration.generated_doc_disclaimer << "\n" if generated?
        new_header << generate_apis_code(apis)
        new_header << ensure_line_breaks(old_header.lines).reject do |line|
          line.include?(Apipie.configuration.generated_doc_disclaimer) ||
            line =~ /^api/
        end.join
        overwrite_header(new_header)
      end

      def update_generated_description(desc)
        if generated? || old_header.empty?
          new_header = generate_code(desc)
          overwrite_header(new_header)
        end
      end

      def update(new_header)
        overwrite_header(new_header)
      end

      def old_header
        return @old_header if defined? @old_header
        @old_header = lines_above_method[/^\s*?#{Regexp.escape(Apipie.configuration.generated_doc_disclaimer)}.*/m]
        @old_header ||= lines_above_method[/^\s*?\b(api|params|error|example)\b.*/m]
        @old_header ||= ""
        @old_header.sub!(/\A\s*\n/,"")
        @old_header = align_indented(@old_header)
      end

      def write!
        File.open(controller_path, "w") { |f| f << @controller_content }
        @changed=false
      end

      protected

      def logger
        Extractor.logger
      end

      def action_line
        return @action_line if defined? @action_line
        @action_line = ensure_line_breaks(controller_content.lines).find_index { |line| line =~ /def \b#{@action}\b/ }
        raise ActionNotFound unless @action_line
        @action_line
      end

      def controller_path
        @controller_path ||= File.join(Rails.root, "app", "controllers", "#{@controller.controller_path}_controller.rb")
      end

      def controller_content
        raise ControllerNotFound.new unless File.exists? controller_path
        @controller_content ||= File.read(controller_path)
      end

      def controller_content=(new_content)
        return if @controller_name == new_content
        remove_instance_variable("@action_line")
        remove_instance_variable("@old_header")
        @controller_content=new_content
        @changed = true
      end

      def generate_code(desc)
        code = "#{Apipie.configuration.generated_doc_disclaimer}\n"
        code << generate_apis_code(desc[:api])
        code << generate_params_code(desc[:params])
        code << generate_errors_code(desc[:errors])
        return code
      end

      def generate_apis_code(apis)
        code = ""
        apis.sort_by {|a| a[:path] }.each do |api|
          desc = api[:desc]
          name = @controller.controller_name.gsub("_", " ")
          desc ||= case @action.to_s
                   when "show", "create", "update", "destroy"
                     name = name.singularize
                     "#{@action.capitalize} #{name =~ /^[aeiou]/ ? "an" : "a"} #{name}"
                   when "index"
                     "List #{name}"
                   end

          code << "api :#{api[:method]}, \"#{api[:path]}\""
          code << ", \"#{desc}\"" if desc
          code << "\n"
        end
        return code
      end

      def generate_params_code(params, indent = "")
        code = ""
        params.sort_by {|n,_| n }.each do |(name, desc)|
          desc[:type] = (desc[:type] && desc[:type].first) || Object
          code << "#{indent}param"
          if name =~ /\W/
            code << " :\"#{name}\""
          else
            code << " :#{name}"
          end
          code << ", #{desc[:type].inspect}"
          if desc[:allow_nil]
            code << ", :allow_nil => true"
          end
          if desc[:required]
            code << ", :required => true"
          end
          if desc[:nested]
            code << " do\n"
            code << generate_params_code(desc[:nested], indent + "  ")
            code << "#{indent}end"
          else
          end
          code << "\n"
        end
        code
      end

      def generate_errors_code(errors)
        code = ""
        errors.sort_by {|e| e[:code] }.each do |error|
          code << "error :code => #{error[:code]}\n"
        end
        code
      end

      def align_indented(text)
        shift_left = ensure_line_breaks(text.lines).map { |l| l[/^\s*/].size }.min
        ensure_line_breaks(text.lines).map { |l| l[shift_left..-1] }.join
      end

      def overwrite_header(new_header)
        overwrite_line_from = action_line
        overwrite_line_to = action_line
        unless old_header.empty?
          overwrite_line_from -= ensure_line_breaks(old_header.lines).count
        end
        lines = ensure_line_breaks(controller_content.lines).to_a
        indentation = lines[action_line][/^\s*/]
        self.controller_content= (lines[0...overwrite_line_from] +
                              [new_header.gsub(/^/,indentation)] +
                              lines[overwrite_line_to..-1]).join
      end

      # returns all the lines before the method that might contain the restpi descriptions
      # not bulletproof but working for conventional Ruby code
      def lines_above_method
        added_lines = []
        lines_to_add = []
        block_level = 0
        ensure_line_breaks(controller_content.lines).first(action_line).reverse_each do |line|
          if line =~ /\s*\bend\b\s*/
            block_level += 1
          end
          if block_level > 0
            lines_to_add << line
          else
            added_lines << line
          end
          if line =~ /\s*\b(module|class|def)\b /
            break
          end
          if line =~ /do\s*(\|.*?\|)?\s*$/
            block_level -= 1
            if block_level == 0
              added_lines.concat(lines_to_add)
              lines_to_add = []
            end
          end
        end
        return added_lines.reverse.join
      end

      # this method would be totally useless unless some clever guy
      # desided that it would be great idea to change a behavior of
      # "".lines method to not include end of lines.
      #
      # For more details:
      #   https://github.com/puppetlabs/puppet/blob/0dc44695/lib/puppet/util/monkey_patches.rb
      def ensure_line_breaks(lines)
        if lines.to_a.size > 1 && lines.first !~ /\n\Z/
          lines.map { |l| l !~ /\n\Z/ ? (l << "\n") : l }.to_enum
        else
          lines
        end
      end
    end

    # Used to keep apipie_examples.yml params in order
    class OrderedHash < ActiveSupport::OrderedHash

      def to_yaml_type
        "!tag:yaml.org,2002:map"
      end

      def to_yaml(opts = {})
        YAML.quick_emit(self, opts) do |out|
          out.map(taguri) do |map|
            each do |k, v|
              map.add(k, v)
            end
          end
        end
      end
    end

  end
end
