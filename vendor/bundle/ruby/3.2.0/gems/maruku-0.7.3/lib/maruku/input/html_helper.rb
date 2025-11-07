module MaRuKu::In::Markdown::SpanLevelParser

  # This class helps me read and sanitize HTML blocks
  class HTMLHelper
    Tag = %r{^<(/)?(\w+)\s*([^>]*?)>}m
    PartialTag = %r{^<.*}m
    CData = %r{^\s*<!\[CDATA\[}m
    CDataEnd = %r{\]\]>}m

    EverythingElse = %r{^[^<]+}m
    CommentStart = %r{^<!--}x
    CommentEnd = %r{-->}
    TO_SANITIZE = ['img', 'hr', 'br']

    attr_reader :rest, :first_tag

    def initialize
      @rest = ""
      @tag_stack = []
      @m = nil
      @already = ""
      self.state = :inside_element
    end

    attr_accessor :state # = :inside_element, :inside_tag, :inside_comment, :inside_cdata

    def eat_this(line)
      @rest = line + @rest
      things_read = 0
      until @rest.empty?
        case self.state
        when :inside_comment
          if @m = CommentEnd.match(@rest)
            debug_state 'Comment End'
            # Workaround for https://bugs.ruby-lang.org/issues/9277 and another bug in 1.9.2 where even a
            # single dash in a comment will cause REXML to error.
            @already << @m.pre_match.gsub(/-(?![^\-])/, '- ') << @m.to_s
            @rest = @m.post_match
            self.state = :inside_element
          else
            @already << @rest.gsub(/-(?![^\-])/, '- ') # Workaround for https://bugs.ruby-lang.org/issues/9277
            @rest = ""
            self.state = :inside_comment
          end
        when :inside_element
          if @m = CommentStart.match(@rest)
            debug_state 'Comment'
            things_read += 1
            @already << @m.pre_match << @m.to_s
            @rest = @m.post_match
            self.state = :inside_comment
          elsif @m = Tag.match(@rest)
            debug_state 'Tag'
            things_read += 1
            self.state = :inside_element
            handle_tag
          elsif @m = CData.match(@rest)
            debug_state 'CDATA'
            @already << @m.pre_match
            close_script_style if script_style?
            @already << @m.to_s
            @rest = @m.post_match
            self.state = :inside_cdata
          elsif @m = PartialTag.match(@rest)
            debug_state 'PartialTag'
            @already << @m.pre_match
            @rest = @m.post_match
            @partial_tag = @m.to_s
            self.state = :inside_tag
          elsif @m = EverythingElse.match(@rest)
            debug_state 'EverythingElse'
            @already << @m.pre_match << @m.to_s
            @rest = @m.post_match
            self.state = :inside_element
          else
            error "Malformed HTML: not complete: #{@rest.inspect}"
          end
        when :inside_tag
          if @m = /^[^>]*>/.match(@rest)
            @partial_tag << @m.to_s
            @rest = @partial_tag + @m.post_match
            @partial_tag = nil
            self.state = :inside_element
            if @m = Tag.match(@rest)
              things_read += 1
              handle_tag
            end
          else
            @partial_tag << @rest
            @rest = ""
            self.state = :inside_tag
          end
        when :inside_cdata
          if @m = CDataEnd.match(@rest)
            self.state = :inside_element
            @already << @m.pre_match << @m.to_s
            @rest = @m.post_match
            start_script_style if script_style?
          else
            @already << @rest
            @rest = ""
            self.state = :inside_cdata
          end
        else
          raise "Bug bug: state = #{self.state.inspect}"
        end

        break if is_finished? && things_read > 0
      end
    end

    def handle_tag
      @already << @m.pre_match
      @rest = @m.post_match

      is_closing = !!@m[1]
      tag = @m[2]
      @first_tag ||= tag
      attributes = @m[3].to_s

      is_single = false
      if attributes[-1, 1] == '/'
        attributes = attributes[0, attributes.size - 1]
        is_single = true
      end

      if TO_SANITIZE.include? tag
        attributes.strip!
        if attributes.size > 0
          @already << '<%s %s />' % [tag, attributes]
        else
          @already << '<%s />' % [tag]
        end
      elsif is_closing
        if @tag_stack.empty?
          error "Malformed: closing tag #{tag.inspect} in empty list"
        elsif @tag_stack.last != tag
          error "Malformed: tag <#{tag}> closes <#{@tag_stack.last}>"
        end

        close_script_style if script_style?

        @already << @m.to_s
        @tag_stack.pop
      else
        @already << @m.to_s
        @tag_stack.push(tag) unless is_single

        start_script_style if script_style?
      end
    end

    def stuff_you_read
      @already
    end

    def is_finished?
      self.state == :inside_element && @tag_stack.empty?
    end

    private

    def debug_state(note)
      my_debug "#{@state}: #{note}: #{@m.to_s.inspect}"
    end

    def my_debug(s)
      #    puts "---" * 10 + "\n" + inspect + "\t>>>\t" + s
    end

    def error(s)
      raise "Error: #{s} \n" + inspect, caller
    end

    def inspect
      "HTML READER\n state=#{self.state} " +
        "match=#{@m.to_s.inspect}\n" +
        "Tag stack = #{@tag_stack.inspect} \n" +
        "Before:\n" +
        @already.gsub(/^/, '|') + "\n" +
        "After:\n" +
        @rest.gsub(/^/, '|') + "\n"
    end

    # Script and style tag handling
    # -----------------------------
    #
    # XHTML, and XML parsers like REXML, require that certain characters be
    # escaped within script or style tags. However, there are conflicts between
    # documents served as XHTML vs HTML. So we need to be extra careful about
    # how we escape these tags so they will even parse correctly. However, we
    # also try to avoid adding that escaping unnecessarily.
    #
    # See http://dorward.me.uk/www/comments-cdata/ for a good explanation.

    # Are we within a script or style tag?
    def script_style?
      %w(script style).include?(@tag_stack.last)
    end

    # Save our @already buffer elsewhere, and switch to using @already for the
    # contents of this script or style tag.
    def start_script_style
      @before_already, @already = @already, ""
    end

    # Finish script or style tag content, wrapping it in CDATA if necessary,
    # and add it to our original @already buffer.
    def close_script_style
      tag = @tag_stack.last

      # See http://www.w3.org/TR/xhtml1/#C_4 for character sequences not allowed within an element body.
      if @already =~ /<|&|\]\]>|--/
        new_already = script_style_cdata_start(tag)
        new_already << "\n" unless @already.start_with?("\n")
        new_already << @already
        new_already << "\n" unless @already.end_with?("\n")
        new_already << script_style_cdata_end(tag)
        @already = new_already
      end
      @before_already << @already
      @already = @before_already
    end

    def script_style_cdata_start(tag)
      (tag == 'script') ? "//<![CDATA[" : "/*<![CDATA[*/"
    end

    def script_style_cdata_end(tag)
      (tag == 'script') ? "//]]>" : "/*]]>*/"
    end
  end
end
