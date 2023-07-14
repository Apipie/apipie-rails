# frozen_string_literal: true

module Apipie
  class ParamDescription
    # Data transfer object, used when param description is deprecated
    class Deprecation
      attr_reader :info, :deprecated_in, :sunset_at

      def initialize(info: nil, deprecated_in: nil, sunset_at: nil)
        @info = info
        @deprecated_in = deprecated_in
        @sunset_at = sunset_at
      end

      def to_json(*_args)
        {
          info: @info,
          deprecated_in: @deprecated_in,
          sunset_at: @sunset_at
        }
      end
    end
  end
end
