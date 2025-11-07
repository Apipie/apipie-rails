require 'strscan'

module MaRuKu::In::Markdown::SpanLevelParser

  # a string scanner coded by me
  class CharSourceManual; end

  # a wrapper around StringScanner
  class CharSourceStrscan; end

  # A debug scanner that checks the correctness of both
  # by comparing their output
  class CharSourceDebug; end

  # Choose!

  CharSource = CharSourceManual     # faster! 58ms vs. 65ms
  #CharSource = CharSourceStrscan   # Faster on LONG documents. But StringScanner is buggy in Rubinius
  #CharSource = CharSourceDebug


  class CharSourceManual
    def initialize(s, parent=nil)
      raise "Passed #{s.class}" if not s.kind_of? String
      @buffer = s
      @buffer_index = 0
      @parent = parent
    end

    # Return current char as a String (or nil).
    def cur_char
      cur_chars(1)
    end

    # Return the next n chars as a String.
    def cur_chars(n)
      return nil if @buffer_index >= @buffer.size
      @buffer[@buffer_index, n]
    end

    # Return the char after current char as a String (or nil).
    def next_char
      return nil if @buffer_index + 1 >= @buffer.size
      @buffer[@buffer_index + 1, 1]
    end

    def shift_char
      c = cur_char
      @buffer_index += 1
      c
    end

    def ignore_char
      @buffer_index += 1
    end

    def ignore_chars(n)
      @buffer_index += n
    end

    def current_remaining_buffer
      @buffer[@buffer_index, @buffer.size - @buffer_index]
    end

    def cur_chars_are(string)
      cur_chars(string.size) == string
    end

    def next_matches(r)
      r2 = /^.{#{@buffer_index}}#{r}/m
      r2.match @buffer
    end

    def read_regexp(r)
      r2 = /^#{r}/
      rest = current_remaining_buffer
      m = r2.match(rest)
      if m
        @buffer_index += m.to_s.size
      end
      m
    end

    def consume_whitespace
      while c = cur_char
        break unless (c == ' ' || c == "\t")
        ignore_char
      end
    end

    def describe
      s = describe_pos(@buffer, @buffer_index)
      if @parent
        s += "\n\n" + @parent.describe
      end
      s
    end

    def describe_pos(buffer, buffer_index)
      len = 75
      num_before = [len/2, buffer_index].min
      num_after = [len/2, buffer.size - buffer_index].min
      num_before_max = buffer_index
      num_after_max = buffer.size - buffer_index

      num_before = [num_before_max, len - num_after].min
      num_after  = [num_after_max, len - num_before].min

      index_start = [buffer_index - num_before, 0].max
      index_end   = [buffer_index + num_after, buffer.size].min

      size = index_end - index_start

      str = buffer[index_start, size]
      str.gsub!("\n", 'N')
      str.gsub!("\t", 'T')

      if index_end == buffer.size
        str += "EOF"
      end

      pre_s = buffer_index - index_start
      pre_s = [pre_s, 0].max
      pre_s2 = [len - pre_s, 0].max
      pre = " " * pre_s

      "-" * len + "\n" +
        str + "\n" +
        "-" * pre_s + "|" + "-" * pre_s2 + "\n" +
        pre + "+--- Byte #{buffer_index}\n"+

        "Shown bytes [#{index_start} to #{size}] of #{buffer.size}:\n"+
        buffer.gsub(/^/, ">")
    end
  end

  class CharSourceStrscan

    def initialize(s, parent=nil)
      @scanner = StringScanner.new(s)
      @size = s.size
    end

    # Return current char as a String (or nil).
    def cur_char
      @scanner.peek(1)[0]
    end

    # Return the next n chars as a String.
    def cur_chars(n)
      @scanner.peek(n)
    end

    # Return the char after current char as a String (or nil).
    def next_char
      @scanner.peek(2)[1]
    end

    # Return a character as a String, advancing the pointer.
    def shift_char
      @scanner.getch[0]
    end

    # Advance the pointer
    def ignore_char
      @scanner.getch
    end

    # Advance the pointer by n
    def ignore_chars(n)
      n.times { @scanner.getch }
    end

    # Return the rest of the string
    def current_remaining_buffer
      @scanner.rest
    end

    # Returns true if string matches what we're pointing to
    def cur_chars_are(string)
      @scanner.peek(string.size) == string
    end

    # Returns true if Regexp r matches what we're pointing to
    def next_matches(r)
      @scanner.check(r)
    end

    def read_regexp(r)
      r.match(@scanner.scan(r))
    end

    def consume_whitespace
      @scanner.skip(/\s+/)
    end

    def describe
      len = 75
      num_before = [len/2, @scanner.pos].min
      num_after = [len/2, @scanner.rest_size].min
      num_before_max = @scanner.pos
      num_after_max = @scanner.rest_size

      num_before = [num_before_max, len - num_after].min
      num_after  = [num_after_max, len - num_before].min

      index_start = [@scanner.pos - num_before, 0].max
      index_end   = [@scanner.pos + num_after, @size].min

      size = index_end - index_start

      str = @scanner.string[index_start, size]
      str.gsub!("\n", 'N')
      str.gsub!("\t", 'T')

      if index_end == @size
        str += "EOF"
      end

      pre_s = @scanner.pos - index_start
      pre_s = [pre_s, 0].max
      pre_s2 = [len-pre_s, 0].max
      pre = " " * pre_s

      "-" * len + "\n" +
        str + "\n" +
        "-" * pre_s + "|" + "-" * pre_s2 + "\n" +
        pre + "+--- Byte #{@scanner.pos}\n" +
        "Shown bytes [#{index_start} to #{size}] of #{@size}:\n" +
        @scanner.string.gsub(/^/, ">")
    end
  end

  class CharSourceDebug
    def initialize(s, parent)
      @a = CharSourceManual.new(s, parent)
      @b = CharSourceStrscan.new(s, parent)
    end

    def method_missing(methodname, *args)
      a_bef = @a.describe
      b_bef = @b.describe

      a = @a.send(methodname, *args)
      b = @b.send(methodname, *args)

      if a.kind_of? MatchData
        if a.to_a != b.to_a
          puts "called: #{methodname}(#{args})"
          puts "Matchdata:\na = #{a.to_a.inspect}\nb = #{b.to_a.inspect}"
          puts "AFTER: " + @a.describe
          puts "AFTER: " + @b.describe
          puts "BEFORE: " + a_bef
          puts "BEFORE: " + b_bef
          puts caller.join("\n")
          exit
        end
      else
        if a != b
          puts "called: #{methodname}(#{args})"
          puts "Attenzione!\na = #{a.inspect}\nb = #{b.inspect}"
          puts "" + @a.describe
          puts "" + @b.describe
          puts caller.join("\n")
          exit
        end
      end

      if @a.cur_char != @b.cur_char
        puts "Fuori sincronia dopo #{methodname}(#{args})"
        puts "" + @a.describe
        puts "" + @b.describe
        exit
      end

      return a
    end
  end
end
