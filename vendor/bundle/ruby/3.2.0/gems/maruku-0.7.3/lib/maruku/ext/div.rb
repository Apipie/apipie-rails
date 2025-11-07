#+-----------------------------------{.warning}------
#| this is the last warning!
#|
#| please, go away!
#|
#| +------------------------------------- {.menace} --
#| | or else terrible things will happen
#| +--------------------------------------------------
#+---------------------------------------------------

# TODO: Scope these properly
OpenDiv = /^[ ]{0,3}\+\-\-+\s*(\{([^{}]*?|".*?"|'.*?')*\})?\s*\-*\s*$/
CloseDiv = /^[ ]{0,3}\=\-\-+\s*(\{([^{}]*?|".*?"|'.*?')*\})?\s*\-*\s*$/
StartPipe = /^[ ]{0,3}\|(.*)$/ # $1 is rest of line
DecorativeClosing = OpenDiv

MaRuKu::In::Markdown.register_block_extension(
  :regexp  => OpenDiv,
  :handler => lambda do |doc, src, context|
    first = src.shift_line
    ial_at_beginning = first[OpenDiv, 1]
    ial_at_end = nil

    lines = []
    # if second line starts with "|"
    if src.cur_line =~ StartPipe
      # then we read until no more "|"
      while src.cur_line && src.cur_line =~ StartPipe
        lines.push $1
        src.shift_line
      end
      if src.cur_line =~ DecorativeClosing
        ial_at_end = $1
        src.shift_line
      end
    else
      # else we read until CloseDiv
      divs_open = 1
      while src.cur_line && divs_open > 0
        if src.cur_line =~ CloseDiv
          divs_open -= 1
          if divs_open == 0
            ial_at_end = $1
            src.shift_line
            break
          else
            lines.push src.shift_line
          end
        else
          if src.cur_line =~ OpenDiv
            divs_open += 1
          end
          lines.push src.shift_line
        end
      end

      if divs_open > 0
        doc.maruku_error("At end of input, I still have #{divs_open} DIVs open.",
          src, context)
        next true
      end
    end

    ial_at_beginning = nil unless ial_at_beginning && ial_at_beginning.size > 0
    ial_at_end = nil unless ial_at_end && ial_at_end.size > 0

    if ial_at_beginning && ial_at_end
      doc.maruku_error("Found two conflicting IALs: #{ial_at_beginning.inspect} and #{ial_at_end.inspect}",
        src, context)
    end

    al_string = ial_at_beginning || ial_at_end
    al = nil

    if al_string =~ /^\{(.*)\}\s*$/
      al = al_string && doc.read_attribute_list(
        MaRuKu::In::Markdown::SpanLevelParser::CharSource.new($1),
        nil, [nil])
    end

    context.push(
      doc.md_div(
        doc.parse_blocks(
          MaRuKu::In::Markdown::BlockLevelParser::LineSource.new(lines)),
        al))
    true
  end)

module MaRuKu
  class MDElement
    def md_div(children, al = nil)
      type = label = num = nil
      doc.refid2ref ||= {}
      if al
        al.each do |k, v|
          case k
          when :class; type = $1 if v =~ /^num_(\w*)/
          when :id; label = v
          end
        end
      end

      if type
        doc.refid2ref[type] ||= {}
        num = doc.refid2ref[type].length + 1
        if !label
          doc.id_counter += 1
      		label =  "div_" + doc.id_counter.to_s
        end
      end

      e = self.md_el(:div, children, {:label => label, :type => type, :num => num}, al)
      doc.refid2ref[type].update(label => e) if type && label
      e
    end
  end

  module Out
    module HTML
      def to_html_div
        add_ws wrap_as_element('div')
      end
    end
  end
end
