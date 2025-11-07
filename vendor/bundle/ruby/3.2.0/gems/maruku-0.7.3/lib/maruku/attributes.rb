module MaRuKu
  # This represents a list of attributes specified in the Markdown document
  # that apply to a Markdown-generated tag.
  # What was `{#id .class key="val" ref}` in the Markdown
  # is parsed into `[[:id, 'id'], [:class, 'class'], ['key', 'val'], [:ref, 'ref']]`.
  class AttributeList < Array
    def to_s
      map do |k, v|
        value = quote_if_needed(v)
        case k
        when :id;    "#" + value
        when :class; "." + value
        when :ref;    value
        else quote_if_needed(k) + "=" + value
        end
      end.join(' ')
    end
    alias to_md to_s

    private

    def quote_if_needed(str)
      (str =~ /[\s'"]/) ? str.inspect : str
    end
  end

  module In::Markdown::SpanLevelParser
    def md_al(s = [])
      AttributeList.new(s)
    end

    # @return [AttributeList, nil]
    def read_attribute_list(src, con=nil, break_on_chars=nil)
      break_on_chars = Array(break_on_chars)
      separators = break_on_chars + ['=', ' ', "\t"]
      escaped = Maruku::EscapedCharInQuotes

      al = AttributeList.new
      loop do
        src.consume_whitespace
        break if break_on_chars.include? src.cur_char

        case src.cur_char
        when ':'
          src.ignore_char
        when nil
          break      # we're done here.
        when '='     # error
          src.ignore_char
          maruku_error "In attribute lists, cannot start identifier with `=`."
          tell_user "Ignoring and continuing."
        when '#'     # id definition
          src.ignore_char
          if id = read_quoted_or_unquoted(src, con, escaped, separators)
            al << [:id, id]
          else
            maruku_error 'Could not read `id` attribute.', src, con
            tell_user 'Ignoring bad `id` attribute.'
          end
        when '.'     # class definition
          src.ignore_char
          if klass = read_quoted_or_unquoted(src, con, escaped, separators)
            al << [:class, klass]
          else
            maruku_error 'Could not read `class` attribute.', src, con
            tell_user 'Ignoring bad `class` attribute.'
          end
        else
          unless key = read_quoted_or_unquoted(src, con, escaped, separators)
            maruku_error 'Could not read key or reference.'
            next
          end

          if src.cur_char != '=' && key.length > 0
            al << [:ref, key]
            next
          end

          src.ignore_char # skip the =
          if val = read_quoted_or_unquoted(src, con, escaped, separators)
            al << [key, val]
          else
            maruku_error "Could not read value for key #{key.inspect}.", src, con
            tell_user "Ignoring key #{key.inspect}"
          end
        end
      end
      al
    end

    def merge_ial(elements, src, con)
      # Apply each IAL to the element before
      (elements + [nil]).each_cons(3) do |before, e, after|
        next unless ial?(e)

        if before.kind_of? MDElement
          before.al = e.ial
        elsif after.kind_of? MDElement
          after.al = e.ial
        else
          maruku_error <<ERR, src, con
It's unclear which element the attribute list {:#{e.ial.to_s}}
is referring to. The element before is a #{before.class},
the element after is a #{after.class}.
  before: #{before.inspect}
  after: #{after.inspect}
ERR
        end
      end

      unless Globals[:debug_keep_ials]
        elements.delete_if {|x| ial?(x) && x != elements.first}
      end
    end

    private

    def ial?(e)
      e.is_a?(MDElement) && e.node_type == :ial
    end
  end
end
