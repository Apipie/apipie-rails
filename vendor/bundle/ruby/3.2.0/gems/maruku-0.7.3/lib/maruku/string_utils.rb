require 'strscan'

module MaRuKu
  # Utility functions for dealing with strings.
  module Strings
    TAB_SIZE = 4

    # Split a string into multiple lines,
    # on line feeds and/or carriage returns.
    #
    # @param s [String]
    # @return [String]
    def split_lines(s)
      s.split(/\r\n|\r|\n/)
    end

    # Parses email headers, returning a hash.
    # `hash[:data]` is the message;
    # that is, anything past the headers.
    #
    # Keys are downcased and converted to symbols;
    # spaces become underscores. For example:
    #
    #     !!!plain
    #     My key: true
    #
    # becomes:
    #
    #     {:my_key => true}
    #
    # @param s [String] The email
    # @return [Symbol => String] The header values
    def parse_email_headers(s)
      headers = {}
      scanner = StringScanner.new(s)

      while scanner.scan(/(\w[\w\s\-]+): +(.*)\n/)
        k, v = normalize_key_and_value(scanner[1], scanner[2])
        headers[k.to_sym] = v
      end

      headers[:data] = scanner.rest
      headers
    end

    # This returns the position of the first non-list character
    # in a list item.
    #
    # @example
    # spaces_before_first_char('*Hello') #=> 1
    # spaces_before_first_char('* Hello') #=> 2
    # spaces_before_first_char(' * Hello') #=> 3
    # spaces_before_first_char(' *   Hello') #=> 5
    # spaces_before_first_char('1.Hello') #=> 2
    # spaces_before_first_char(' 1.  Hello') #=> 5
    #
    # @param s [String]
    # @return [Fixnum]
    def spaces_before_first_char(s)
      s = MaRuKu::MDLine.new(s.gsub(/([^\t]*)(\t)/) { $1 + " " * (TAB_SIZE - $1.length % TAB_SIZE) })
      match = case s.md_type
        when :ulist
          # whitespace, followed by ('*'|'+'|'-') followed by
          # more whitespace, followed by an optional IAL, followed
          # by yet more whitespace
          s[/^\s*(\*|\+|\-)\s*(\{[:#\.].*?\})?\s*/]
        when :olist
          # whitespace, followed by a number, followed by a period,
          # more whitespace, an optional IAL, and more whitespace
          s[/^\s*\d+\.\s*(\{[:#\.].*?\})?\s*/]
        else
          tell_user "BUG (my bad): '#{s}' is not a list"
          ''
        end
      f = /\{(.*?)\}/.match(match)
      ial = f[1] if f
      [match.length, ial]
    end

    # Normalize a link reference.
    #
    # @param s [String]
    # @return [String]
    def sanitize_ref_id(s)
      s.downcase.gsub(/\s+/, ' ')
    end

    # Remove line-initial `>` characters for a quotation.
    #
    # @param s [String]
    # @return [String]
    def unquote(s)
      s.gsub(/^>\s?/, '')
    end

    # Removes indentation from the beginning of `s`,
    # up to at most `n` spaces.
    # Tabs are counted as {TAB_SIZE} spaces.
    #
    # @param s [String]
    # @param n [Fixnum]
    # @return [String]
    def strip_indent(s, n)
      while n > 0
        case s[0, 1]
        when ' '
          n -= 1
        when "\t"
          n -= TAB_SIZE
        else
          break
        end
        s = s[1..-1]
      end

      MDLine.new(s)
    end

    private

    # Normalize the key/value pairs for email headers.
    # Keys are downcased and converted to symbols;
    # spaces become underscores.
    #
    # Values of `"yes"`, `"true"`, `"no"`, and `"false"`
    # are converted to appropriate booleans.
    #
    # @param k [String]
    # @param v [String]
    # @return [Array(String, String or Boolean)]
    def normalize_key_and_value(k, v)
      k = k.strip.downcase.gsub(/\s+/, '_').to_sym
      v = v.strip

      # check synonyms
      return k, true if %w[yes true].include?(v.downcase)
      return k, false if %w[no false].include?(v.downcase)
      return k, v
    end
  end
end
