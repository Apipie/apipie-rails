# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To read YARD style documentation from rubocop gem source code
    class Yardoc
      def initialize(cop)
        load_rubocop_gems!
        @cop_class = find_cop_class(cop)
        load_yardoc!
      end

      def description
        yardoc.docstring
      end

      def examples
        yardoc.tags('example').map { |tag| [tag.name, tag.text] }
      end

      # Indicates whether the autocorrect a cop does is safe (equivalent) by design.
      # If a cop is unsafe its autocorrect automatically becomes unsafe as well.
      #
      # @return [Boolean]
      def safe_autocorrect?
        config = RuboCop::ConfigLoader.default_configuration
        cop_class.new(config).safe_autocorrect?
      end

      private

      attr_reader :cop_class, :yardoc

      # Loads gems for YARDoc creation
      def load_rubocop_gems!
        RUBOCOP_GEMS.each do |dependency|
          require dependency
        rescue LoadError
          nil
        end
      end

      # Find a RuboCop class by cop name. It find from rubocop/rspec if cannot
      # find any class from rubocop gem.
      #
      # @param cop [String] The target cop name (e.g. "Performance/Size")
      # @return [RuboCop::Cop] Found a RuboCop::Cop class
      def find_cop_class(cop)
        Object.const_get("RuboCop::Cop::#{cop.gsub('/', '::')}")
      rescue NameError
        Object.const_get("RuboCop::Cop::RSpec::#{cop.gsub('/', '::')}")
      end

      # Loads yardoc from the RuboCop::Cop class file
      def load_yardoc!
        YARD.parse(source_file_path)
        @yardoc = YARD::Registry.all(:class).first
        YARD::Registry.clear
      end

      def instance_methods
        [
          cop_class.instance_methods(false),
          cop_class.private_instance_methods(false)
        ].flatten!
      end

      def source_file_path
        Object.const_source_location(cop_class.name).first
      end
    end
  end
end
