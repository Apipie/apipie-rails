module MaRuKu::In::Markdown::SpanLevelParser
  include MaRuKu::Helpers

  EscapedCharInText = '\\`*_{}[]()#.!|:+->'.split(//)
  EscapedCharInQuotes = EscapedCharInText + ["'", '"']

  EscapedCharInInlineCode = ['\\', '`']

  IgnoreWikiLinks = MaRuKu::Globals[:ignore_wikilinks]

  def parse_span(string, parent=nil)
    string = Array(string).join("\n") unless string.kind_of? String
    src = MaRuKu::In::Markdown::SpanLevelParser::CharSource.new(string, parent)
    read_span(src, EscapedCharInText, [nil])
  end

  # This is the main loop for reading span elements
  #
  # It's long, but not *complex* or difficult to understand.
  #
  #
  def read_span(src, escaped, exit_on_chars=nil, exit_on_strings=nil)
    escaped = Array(escaped)
    con = SpanContext.new
    dquote_state = squote_state = :closed
    c = d = prev_char = nil
    while true
      c = src.cur_char

      # This is only an optimization which cuts 50% of the time used.
      # (but you can't use a-zA-z in exit_on_chars)
      if c && c =~  /[[:alnum:]]/
        con.push_char src.shift_char
        prev_char = c
        next
      end

      break if Array(exit_on_chars).include?(c)
      if Array(exit_on_strings).any? {|x| src.cur_chars_are x }
        # Special case: bold nested in italic
        break unless !(['*', '_'] & Array(exit_on_strings)).empty? &&
          ['**', '__'].include?(src.cur_chars(2)) &&
          !['***', '___'].include?(src.cur_chars(3))
      end

      # check if there are extensions
      next if check_span_extensions(src, con)

      case c = src.cur_char
      when ' '
        if src.cur_chars_are "  \n"
          src.ignore_chars(3)
          con.push_element md_br
          prev_char = ' '
          next
        elsif src.cur_chars_are ' >>' # closing guillemettes
          src.ignore_chars(3)
          con.push_element md_entity('nbsp')
          con.push_element md_entity('raquo')
        elsif src.cur_chars(5) =~ / '\d\ds/ # special case: '80s
          src.ignore_chars(2)
          con.push_space
          con.push_element md_entity('rsquo')
        elsif src.cur_chars_are " '" # opening single-quote
          src.ignore_chars(2)
          con.push_space
          con.push_element md_entity('lsquo')
          squote_state = :open
        else
          src.ignore_char
          con.push_space
        end
      when "\n", "\t"
        src.ignore_char
        con.push_space
      when '`'
        read_inline_code(src, con)
      when '<'
        # It could be:
        # 1) HTML "<div ..."
        # 2) HTML "<!-- ..."
        # 3) url "<http:// ", "<ftp:// ..."
        # 4) email "<andrea@... ", "<mailto:andrea@..."
        # 5) on itself! "a < b  "
        # 6) Start of <<guillemettes>>

        case d = src.next_char
        when '<'  # guillemettes
          if src.cur_chars_are '<< '
            src.ignore_chars(3)
            con.push_element md_entity('laquo')
            con.push_element md_entity('nbsp')
          else
            src.ignore_chars(2)
            con.push_element md_entity('laquo')
          end
        when '!'
          if src.cur_chars_are '<!--'
            read_inline_html(src, con)
          else
            con.push_char src.shift_char
          end
        when '?'
          read_xml_instr_span(src, con)
        when ' ', "\t"
          con.push_char src.shift_char
        else
          if src.next_matches(/<mailto:/) ||
              src.next_matches(/<[\w\.]+\@/)
            read_email_el(src, con)
          elsif src.next_matches(/<\w+:/)
            read_url_el(src, con)
          elsif src.next_matches(/<\w/)
            #puts "This is HTML: #{src.cur_chars(20)}"
            read_inline_html(src, con)
          else
            #puts "This is NOT HTML: #{src.cur_chars(20)}"
            con.push_char src.shift_char
          end
        end
      when '>'
        if src.next_char == '>'
          src.ignore_chars(2)
          con.push_element md_entity('raquo')
        else
          con.push_char src.shift_char
        end
      when "\\"
        d = src.next_char
        if d == "'"
          src.ignore_chars(2)
          con.push_element md_entity('apos')
        elsif d == '"'
          src.ignore_chars(2)
          con.push_element md_entity('quot')
        elsif escaped.include? d
          src.ignore_chars(2)
          con.push_char d
        else
          con.push_char src.shift_char
        end
      when '['
        if markdown_extra? && src.next_char == '^'
          read_footnote_ref(src,con)
        elsif IgnoreWikiLinks && src.next_char == '['
          con.push_char src.shift_char
          con.push_char src.shift_char
        else
          read_link(src, con)
        end
      when '!'
        if src.next_char == '['
          read_image(src, con)
        else
          con.push_char src.shift_char
        end
      when '&'
        # named references
        if m = src.read_regexp(/\&(\w+);/)
          con.push_element md_entity(m[1])
          # numeric
        elsif m = src.read_regexp(/\&\#(x)?(\w+);/)
          num = m[1] ? m[2].hex : m[2].to_i
          con.push_element md_entity(num)
        else
          con.push_char src.shift_char
        end
      when '*'
        if !src.next_char
          maruku_error "Opening * as last char.", src, con, 'Treating as literal'
          con.push_char src.shift_char
        else
          follows = src.cur_chars(4)
          if follows =~ /^\*\*\*[^\s\*]/
            con.push_element read_emstrong(src, '***')
          elsif follows  =~ /^\*\*[^\s\*]/
            con.push_element read_strong(src, '**')
          elsif follows =~ /^\*[^\s\*]/
            con.push_element read_em(src, '*')
          else # * is just a normal char
            con.push_char src.shift_char
          end
        end
      when '_'
        if !src.next_char
          maruku_error "Opening _ as last char", src, con, 'Treating as literal'
          con.push_char src.shift_char
        else
          # we don't want "mod_ruby" to start an emphasis
          # so we start one only if
          # 1) there's nothing else in the span (first char)
          # or 2) the last char was a space
          # or 3) the current string is empty
          #if con.elements.empty? ||
          if con.is_end?
            # also, we check the next characters
            follows = src.cur_chars(4)
            if  follows =~ /^\_\_\_[^\s\_]/
              con.push_element read_emstrong(src, '___')
            elsif follows  =~ /^\_\_[^\s\_]/
              con.push_element read_strong(src, '__')
            elsif follows =~ /^\_[^\s\_]/
              con.push_element read_em(src, '_')
            else # _ is just a normal char
              con.push_char src.shift_char
            end
          else
            # _ is just a normal char
            con.push_char src.shift_char
          end
        end
      when '{' # extension
        if ['#', '.', ':'].include? src.next_char
          src.ignore_char # {
          interpret_extension(src, con, '}')
          src.ignore_char # }
        else
          con.push_char src.shift_char
        end
      when nil
        maruku_error( ("Unclosed span (waiting for %s" +
                       "#{exit_on_strings.inspect})") %
                      [ exit_on_chars ? "#{exit_on_chars.inspect} or" : "" ],
                      src, con)
        break
      when '-' # dashes
        if src.next_char == '-'
          if src.cur_chars_are '---'
            src.ignore_chars(3)
            con.push_element md_entity('mdash')
          else
            src.ignore_chars(2)
            con.push_element md_entity('ndash')
          end
        else
          con.push_char src.shift_char
        end
      when '.' # ellipses
        if src.cur_chars_are '...'
          src.ignore_chars(3)
          con.push_element md_entity('hellip')
        elsif src.cur_chars_are '. . .'
          src.ignore_chars(5)
          con.push_element md_entity('hellip')
        else
          con.push_char src.shift_char
        end
      when '"'
        if dquote_state == :closed
          dquote_state = :open
          src.ignore_char
          con.push_element md_entity('ldquo')
        else
          dquote_state = :closed
          src.ignore_char
          con.push_element md_entity('rdquo')
        end
      when "'"
        if src.cur_chars(4) =~ /'\d\ds/ # special case: '80s
          src.ignore_char
          con.push_element md_entity('rsquo')
        elsif squote_state == :open
          squote_state = :closed unless src.next_char =~ /[[:alpha:]]/
          src.ignore_char
          con.push_element md_entity('rsquo')
        else
          if prev_char =~ /[[:alpha:]]/
            src.ignore_char
            con.push_element md_entity('rsquo')
          else
            src.ignore_char
            con.push_element md_entity('lsquo')
            squote_state = :open
          end
        end
      else # normal text
        con.push_char src.shift_char
      end # end case
      prev_char = c
    end # end while true

    con.push_string_if_present

    # Assign IAL to elements
    merge_ial(con.elements, src, con)

    # Remove leading space
    if (s = con.elements.first).kind_of? String
      if s[0, 1] == ' '
        con.elements[0] = s[1..-1]
      end
      con.elements.shift if s.empty?
    end
    
    con.elements.shift if (con.elements.first.kind_of?(String) && con.elements.first.empty?)

    # Remove final spaces
    if (s = con.elements.last).kind_of? String
      s.chop! if s[-1, 1] == ' '
      con.elements.pop if s.empty?
    end

    con.elements
  end


  def read_xml_instr_span(src, con)
    src.ignore_chars(2) # starting <?

    # read target <?target code... ?>
    target = if m = src.read_regexp(/^(\w+)/)
               m[1]
             else
               # XML instructions are invalid without a target
               ''
             end

    delim = "?>"

    code = read_simple(src, nil, nil, delim)

    src.ignore_chars delim.size

    code = (code || "").strip
    con.push_element md_xml_instr(target, code)
  end

  # Start: cursor on character **after** '{'
  # End: curson on '}' or EOF
  def interpret_extension(src, con, break_on_chars=nil)
    case src.cur_char
    when ':'
      src.ignore_char # :
      extension_meta(src, con, break_on_chars)
    when '#', '.'
      extension_meta(src, con, break_on_chars)
    else
      stuff = read_simple(src, '}', break_on_chars)
      if stuff =~ /^(\w+\s|[^\w])/
        extension_id = $1.strip

        maruku_recover "I don't know what to do with extension '#{extension_id}'\n" +
          "I will treat this:\n\t{#{stuff}} \n as meta-data.\n", src, con
      else
        maruku_recover "I will treat this:\n\t{#{stuff}} \n as meta-data.\n", src, con
      end
      extension_meta(src, con, break_on_chars)
    end
  end

  def extension_meta(src, con, break_on_chars=nil)
    if m = src.read_regexp(/([^\s\:\"\'}]+?):/)
      name = m[1]
      al = read_attribute_list(src, con, break_on_chars)
      self.doc.ald[name] = al
      con.push md_ald(name, al)
    else
      al = read_attribute_list(src, con, break_on_chars)
      con.push md_ial(al)
    end
  end

  def read_url_el(src,con)
    src.ignore_char # leading <
    url = read_simple(src, nil, '>')
    src.ignore_char # closing >

    con.push_element md_url(url)
  end

  def read_email_el(src,con)
    src.ignore_char # leading <
    mail = read_simple(src, nil, '>')
    src.ignore_char # closing >

    address = mail.gsub(/^mailto:/, '')
    con.push_element md_email(address)
  end

  def read_url(src, break_on)
    if ["'", '"'].include? src.cur_char
      maruku_error 'Invalid char for url', src
    end

    url = read_simple(src, nil, break_on) || ''

    if url[0, 1] == '<' && url[-1, 1] == '>'
      url = url[1, url.size-2]
    end

    return nil if url.empty?
    url
  end


  def read_quoted_or_unquoted(src, con, escaped, exit_on_chars)
    case src.cur_char
    when "'", '"'
      read_quoted(src, con)
    else
      read_simple(src, escaped, exit_on_chars, nil, false)
    end
  end

  # Tries to read a quoted value. If stream does not
  # start with ' or ", returns nil.
  def read_quoted(src, con)
    case src.cur_char
    when "'", '"'
      quote_char = src.shift_char # opening quote
      string = read_simple(src, EscapedCharInQuotes, quote_char)
      src.ignore_char # closing quote
      string
    else
      nil
    end
  end

  # Reads a simple string (no formatting) until one of exit_on_chars,
  # while escaping the escaped.
  # If the string is empty, it returns nil.
  # By default, raises on error if the string terminates unexpectedly. This can be
  # by setting the last argument to false.
  def read_simple(src, escaped, exit_on_chars=nil, exit_on_strings=nil, warn=true)
    text = ""
    escaped = Array(escaped)
    exit_on_chars = Array(exit_on_chars)
    exit_on_strings = Array(exit_on_strings)
    while true
      c = src.cur_char

      break if exit_on_chars.include?(c)
      break if exit_on_strings.any? {|x| src.cur_chars_are x }

      case c
      when nil
        if warn
          maruku_error "String finished while reading (break on " +
            "#{(exit_on_chars + exit_on_strings).inspect})" +
            " already read: #{text.inspect}", src
        end
        break
      when "\\"
        d = src.next_char
        if escaped.include? d
          src.ignore_chars(2)
          text << d
        else
          text << src.shift_char
        end
      else
        text << src.shift_char
      end
    end

    text.empty? ? nil : text
  end

  def read_em(src, delim)
    src.ignore_char
    children = read_span(src, EscapedCharInText, nil, delim)
    src.ignore_char
    md_em(children)
  end

  def read_strong(src, delim)
    src.ignore_chars(2)
    children = read_span(src, EscapedCharInText, nil, delim)
    src.ignore_chars(2)
    md_strong(children)
  end

  def read_emstrong(src, delim)
    src.ignore_chars(3)
    children = read_span(src, EscapedCharInText, nil, delim)
    src.ignore_chars(3)
    md_emstrong(children)
  end

  # Reads a bracketed id "[refid]". Consumes also both brackets.
  def read_ref_id(src, con)
    src.ignore_char # [
    if m = src.read_regexp(/([^\]]*?)\]/)
      m[1]
    else
      nil
    end
  end

  def read_footnote_ref(src,con)
    ref = read_ref_id(src,con)
    con.push_element md_foot_ref(ref)
  end

  def read_inline_html(src, con)
    h = HTMLHelper.new
    begin
      # This is our current buffer in the context
      next_stuff = src.current_remaining_buffer

      consumed = 0
      while true
        if consumed >= next_stuff.size
          maruku_error "Malformed HTML starting at #{next_stuff.inspect}", src, con
          break
        end

        h.eat_this next_stuff[consumed].chr
        consumed += 1
        break if h.is_finished?
      end
      src.ignore_chars(consumed)
      con.push_element md_html(h.stuff_you_read)
    rescue => e
      maruku_error "Bad html: \n" +
        e.inspect.gsub(/^/, '>'), src, con, "I will try to continue after bad HTML."
      con.push_char src.shift_char
    end
  end

  def read_inline_code(src, con)
    # Count the number of ticks
    num_ticks = 0
    while src.cur_char == '`'
      num_ticks += 1
      src.ignore_char
    end
    # We will read until this string
    end_string = "`" * num_ticks

    # Try to handle empty single-ticks
    if num_ticks > 1 && !src.next_matches(/.*#{Regexp.escape(end_string)}/)
      con.push_element md_entity('ldquo')
      src.ignore_chars(2)
      return
    end

    code = read_simple(src, nil, nil, end_string)

    # We didn't find a closing batch!
    if !code || src.cur_char != '`'
      con.push_element(end_string + (code || '')) and return
    end

    #   puts "Now I expects #{num_ticks} ticks: #{src.cur_chars(10).inspect}"
    src.ignore_chars num_ticks

    # Ignore at most one space
    if num_ticks > 1 && code[0, 1] == ' '
      code = code[1..-1]
    end

    # drop last space
    if num_ticks > 1 && code[-1, 1] == ' '
      code = code[0..-2]
    end

    #   puts "Read `` code: #{code.inspect}; after: #{src.cur_chars(10).inspect} "
    con.push_element md_code(code)
  end

  def read_link(src, con)
    # we read the string and see what happens
    src.ignore_char # opening bracket
    children = read_span(src, EscapedCharInText, ']')
    src.ignore_char # closing bracket

    # ignore space
    if src.cur_char == ' ' && ['[', '('].include?(src.next_char)
      src.shift_char
    end

    case src.cur_char
    when '('
      src.ignore_char # opening (
      src.consume_whitespace
      url = read_url(src, [' ', "\t", ")"]) || ''

      src.consume_whitespace
      title = nil
      if src.cur_char != ')' # we have a title
        quote_char = src.cur_char
        title = read_quoted(src, con)

        if not title
          maruku_error 'Must quote title', src, con
        else
          # Tries to read a title with quotes: ![a](url "ti"tle")
          # this is the most ugly thing in Markdown
          unless src.next_matches(/\s*\)/)
            # if there is not a closing par ), then read
            # the rest and guess it's title with quotes
            rest = read_simple(src, nil, ')', nil)
            # chop the closing char
            rest.chop!
            title << quote_char << rest
          end
        end
      end
      src.consume_whitespace
      closing = src.shift_char # closing )
      if closing != ')'
        maruku_error 'Unclosed link', src, con, "No closing ): I will not create" +
          " the link for #{children.inspect}"
        con.push_elements children
        return
      end
      con.push_element md_im_link(children, url, title)
    when '[' # link ref
      ref_id = read_ref_id(src, con)
      if ref_id
        con.push_element md_link(children, ref_id)
      else
        maruku_error "Could not read ref_id", src, con, "I will not create the link for " +
          "#{children.inspect}"
        con.push_elements children
        return
      end
    else # empty [link]
      con.push_element md_link(children, nil)
    end
  end # read link

  def read_image(src, con)
    src.ignore_chars(2) # opening "!["
    alt_text = read_span(src, EscapedCharInText, ']')
    src.ignore_char # closing bracket
    # ignore space
    if src.cur_char == ' ' && ['[', '('].include?(src.next_char)
      src.ignore_char
    end
    case src.cur_char
    when '('
      src.ignore_char # opening (
      src.consume_whitespace
      url = read_url(src, [' ', "\t", ')'])
      unless url
        maruku_error "Could not read url from #{src.cur_chars(10).inspect}", src, con
      end
      src.consume_whitespace
      title = nil
      if src.cur_char != ')' # we have a title
        quote_char = src.cur_char
        title = read_quoted(src, con)
        if !title
          maruku_error 'Must quote title', src, con
        else
          # Tries to read a title with quotes: ![a](url "ti"tle")
          # this is the most ugly thing in Markdown
          if !src.next_matches(/\s*\)/)
            # if there is not a closing par ), then read
            # the rest and guess it's title with quotes
            rest = read_simple(src, nil, ')', nil)
            # chop the closing char
            rest.chop!
            title << quote_char << rest
          end
        end
      end
      src.consume_whitespace
      closing = src.shift_char # closing )
      if closing != ')'
        maruku_error "Unclosed link: '#{closing}'" +
          " Read url=#{url.inspect} title=#{title.inspect}", src, con
      end
      con.push_element md_im_image(alt_text, url, title)
    when '[' # link ref
      ref_id = read_ref_id(src, con)
      if !ref_id # TODO: check around
        maruku_error 'Reference not closed.', src, con
        ref_id = ""
      end

      con.push_element md_image(alt_text, ref_id)
    else # no stuff
      ref_id = alt_text.join
      con.push_element md_image(alt_text, ref_id)
    end
  end # read link

  class SpanContext
    # Read elements
    attr_accessor :elements

    def initialize
      @elements = []
      @cur_string = ''
    end

    def push_element(e)
      raise "Only MDElement and String, please. You pushed #{e.class}: #{e.inspect} " unless
        e.kind_of?(String) || e.kind_of?(MaRuKu::MDElement)

      push_string_if_present

      @elements << e
    end
    alias push push_element

    def push_elements(a)
      a.each do |e|
        if e.kind_of? String
          @cur_string << e
        else
          push_element e
        end
      end
    end

    def is_end?
      @cur_string.empty? || @cur_string =~ /\s\z/
    end

    def push_string_if_present
      unless @cur_string.empty?
        @elements << @cur_string
        @cur_string = ''
      end
    end

    def push_char(c)
      @cur_string << c
    end

    # push space into current string if
    # there isn't one
    def push_space
      @cur_string << ' ' unless @cur_string[-1, 1] == ' '
    end

    def describe
      lines = @elements.map{|x| x.inspect }.join("\n")
      s = "Elements read in span: \n" +
        lines.gsub(/^/, ' -') + "\n"

      s += "Current string: \n  #{@cur_string.inspect}\n" unless  @cur_string.empty?
      s
    end
  end
end
