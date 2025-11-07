# frozen_string_literal: true

require "logger"

##
module MIME
  ##
  class Types
    class << self
      # Configure the MIME::Types logger. This defaults to an instance of a
      # logger that passes messages (unformatted) through to Kernel#warn.
      # :attr_accessor: logger
      attr_reader :logger

      ##
      def logger=(logger) # :nodoc
        @logger =
          if logger.nil?
            NullLogger.new
          else
            logger
          end
      end
    end

    class WarnLogger < ::Logger # :nodoc:
      class WarnLogDevice < ::Logger::LogDevice # :nodoc:
        def initialize(*)
        end

        def write(m)
          Kernel.warn(m)
        end

        def close
        end
      end

      def initialize(*)
        super(nil)
        @logdev = WarnLogDevice.new
        @formatter = ->(_s, _d, _p, m) { m }
      end
    end

    class NullLogger < ::Logger
      def initialize(*)
        super(nil)
        @logdev = nil
      end

      def reopen(_)
        self
      end

      def <<(_)
      end

      def close
      end

      def add(_severity, _message = nil, _progname = nil)
      end
    end

    self.logger = WarnLogger.new
  end
end
