module MaRuKu
  class Exception < RuntimeError; end

  module Errors
    FRAME_WIDTH = 75

    # Properly handles a formatting error.
    # All such errors go through this method.
    #
    # The behavior depends on {MaRuKu::Globals `MaRuKu::Globals[:on_error]`}.
    # If this is `:warning`, this prints the error to stderr
    # (or `@error_stream` if it's defined) and tries to continue.
    # If `:on_error` is `:ignore`, this doesn't print anything
    # and tries to continue. If it's `:raise`, this raises a {MaRuKu::Exception}.
    #
    # By default, `:on_error` is set to `:warning`.
    #
    # @overload def maruku_error(s, src = nil, con = nil)
    # @param s [String] The text of the error
    # @param src [#describe, nil] The source of the error
    # @param con [#describe, nil] The context of the error
    # @param recover [String, nil] Recovery text
    # @raise [MaRuKu::Exception] If `:on_error` is set to `:raise`
    def maruku_error(s, src=nil, con=nil, recover=nil)
      policy = get_setting(:on_error)

      case policy
      when :ignore
      when :raise
        raise_error create_frame(describe_error(s, src, con, recover))
      when :warning
        tell_user create_frame(describe_error(s, src, con, recover))
      else
        raise "Unknown on_error policy: #{policy.inspect}"
      end
    end

    # This is like {#maruku_error} but will never raise.
    def maruku_recover(s, src=nil, con=nil, recover=nil)
      policy = get_setting(:on_error)

      case policy
      when :ignore
      when :raise, :warning
        tell_user create_frame(describe_error(s, src, con, recover))
      else
        raise "Unknown on_error policy: #{policy.inspect}"
      end
    end

    def raise_error(s)
      raise MaRuKu::Exception, s, caller
    end

    def tell_user(s)
      (self.attributes[:error_stream] || $stderr) << s << "\n"
    end

    private

    def create_frame(s)
      "\n" + <<FRAME
 #{"_" * FRAME_WIDTH}
| Maruku tells you:
+#{"-" * FRAME_WIDTH}
#{s.gsub(/^/, '| ').rstrip}
+#{"-" * FRAME_WIDTH}
#{caller[1...5].join("\n").gsub(/^/, '!')}
\\#{"_" * FRAME_WIDTH}
FRAME
    end

    def describe_error(s, src=nil, con=nil, recover=nil)
      s += "\n#{src.describe}\n" if src
      s += "\n#{con.describe}\n" if con
      s += "\nRecovering: #{recover}\n" if recover
      s
    end
  end
end
