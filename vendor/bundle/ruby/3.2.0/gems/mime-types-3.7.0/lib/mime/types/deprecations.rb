# frozen_string_literal: true

require "mime/types/logger"

class << MIME::Types
  # Used to mark a method as deprecated in the mime-types interface.
  def deprecated(options = {}, &block) # :nodoc:
    message =
      if options[:message]
        options[:message]
      else
        klass = options.fetch(:class)

        msep = case klass
        when Class, Module
          "."
        else
          klass = klass.class
          "#"
        end

        method = "#{klass}#{msep}#{options.fetch(:method)}"
        pre = " #{options[:pre]}" if options[:pre]
        post = case options[:next]
        when :private, :protected
          " and will be made #{options[:next]}"
        when :removed
          " and will be removed"
        when nil, ""
          nil
        else
          " #{options[:next]}"
        end

        <<-WARNING.chomp.strip
        #{caller(2..2).first}: #{klass}#{msep}#{method}#{pre} is deprecated#{post}.
        WARNING
      end

    if !__deprecation_logged?(message, options[:once])
      MIME::Types.logger.__send__(options[:level] || :debug, message)
    end

    return unless block
    block.call
  end

  private

  def __deprecation_logged?(message, once)
    return false unless once

    @__deprecations_logged = {} unless defined?(@__deprecations_logged)
    @__deprecations_logged.key?(message)
  end
end
