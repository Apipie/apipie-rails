require 'set'
require 'maruku/output/entity_table'

module MaRuKu::Out::Latex
  module MDDocumentExtensions
    # @return [Set<String>]
    attr_accessor :latex_required_packages

    def latex_require_package(p)
      self.latex_required_packages << p
    end

    def initialize(*args)
      self.latex_required_packages = Set.new
      super
    end
  end

  Latex_preamble_enc_cjk =
    "\\usepackage[C40]{fontenc}
\\usepackage[cjkjis]{ucs}
\\usepackage[utf8x]{inputenc}"

  Latex_preamble_enc_utf8 =
    "\\usepackage{ucs}
\\usepackage[utf8x]{inputenc}"

  # Render as a LaTeX fragment
  def to_latex
    children_to_latex
  end

  #=begin maruku_doc
  # Attribute: maruku_signature
  # Scope: document
  # Output: html, latex
  # Summary: Enables Maruku's signature.
  # Default: true
  #
  # If false, Maruku does not append a signature to the
  # generated file.
  #=end

  # Render as a complete LaTeX document
  def to_latex_document
    body = to_latex

    if get_setting(:maruku_signature)
      body << render_latex_signature
    end

    required = self.latex_required_packages.map do |p|
      "\\usepackage{#{p}}\n"
    end.join

    #=begin maruku_doc
    # Attribute: latex_cjk
    # Scope:     document
    # Output:    latex
    # Summary:   Support for CJK characters.
    #
    # If the `latex_cjk` attribute is specified, then appropriate headers
    # are added to the LaTeX preamble to support Japanese fonts.
    # You have to have these fonts installed -- and this can be a pain.
    #
    # If `latex_cjk` is specified, this is added to the preamble:
    #
    # <?mrk puts "ciao" ?>
    #
    # <?mrk md_codeblock(Maruku::MDDocument::Latex_preamble_enc_cjk) ?>
    #
    #
    # while the default is to add this:
    #
    # <?mrk md_codeblock(Maruku::MDDocument::Latex_preamble_enc_utf8) ?>
    #
    #=end

    encoding = get_setting(:latex_cjk) ? Latex_preamble_enc_cjk : Latex_preamble_enc_utf8

    #=begin maruku_doc
    # Attribute: latex_preamble
    # Scope:     document
    # Output:    latex
    # Summary:   User-defined preamble.
    #
    # If the `latex_preamble` attribute is specified, then its value
    # will be used as a custom preamble.
    #
    # For example:
    #
    #   Title: My document
    #   Latex preamble: preamble.tex
    #
    # will produce:
    #
    #   ...
    #   \input{preamble.tex}
    #   ...
    #
    #=end

    user_preamble = (file = @doc.attributes[:latex_preamble]) ? "\\input{#{file}}\n" : ""

    "\\documentclass{article}

% Packages required to support encoding
#{encoding}

% Packages required by code
#{required}

% Packages always used
\\usepackage{hyperref}
\\usepackage{xspace}
\\usepackage[usenames,dvipsnames]{color}
\\hypersetup{colorlinks=true,urlcolor=blue}

#{user_preamble}

\\begin{document}
#{body}
\\end{document}
"
  end

  def render_latex_signature
    "\\vfill
\\hrule
\\vspace{1.2mm}
\\begin{tiny}
Created by \\href{#{MaRuKu::MARUKU_URL}}{Maruku} #{self.nice_date}.
\\end{tiny}"
  end

  def to_latex_hrule
    "\n\\vspace{.5em} \\hrule \\vspace{.5em}\n"
  end

  def to_latex_linebreak
    "\\newline "
  end

  def to_latex_paragraph
    children_to_latex + "\n\n"
  end

  #=begin maruku_doc
  # Title: Input format for colors
  # Output: latex, html
  # Related: code_background_color
  #
  # Admissible formats:
  #
  #   green
  #   #abc
  #   #aabbcc
  #=end

  # \color{name}
  # \color[rgb]{1,0.2,0.3}
  def latex_color(s, command='color')
    if s =~ /\A\#([1-9A-F]{1,2})([1-9A-F]{1,2})([1-9A-F]{1,2})\z/i
      # convert from 0-255 or 0-15 to 0.0-1.0
      r, g, b = [$1, $2, $3].map {|c| c.hex / (c.length == 1 ? 15.0 : 255.0) }
      "\\#{command}[rgb]{%0.2f,%0.2f,%0.2f}" % [r, g, b]
    else
      "\\#{command}{#{s}}"
    end
  end

  #=begin maruku_doc
  # Attribute: code_show_spaces
  # Scope: global, document, element
  #
  # If `true`, shows spaces and tabs in code blocks.
  #
  # Example:
  #
  #      One space
  #       Two spaces
  #         Tab, space, tab
  #           Tab, tab, tab and all is green!
  #   {:code_show_spaces code_background_color=#ffeedd}
  # {:markdown}
  #
  # That will produce:
  #
  #    One space
  #     Two spaces
  #       Tab, space, tab
  #         Tab, tab, tab and all is green!
  # {:code_show_spaces code_background_color=#ffeedd}
  #
  #=end

  #=begin maruku_doc
  # Attribute: latex_use_listings
  # Scope: document
  # Output: latex
  # Summary: Support for `listings` package.
  # Related: code_show_spaces, code_background_color, lang, code_lang
  #
  # If the `latex_use_listings` attribute is specified, then
  # code block are rendered using the `listings` package.
  # Otherwise, a standard `verbatim` environment is used.
  #
  # * If the `lang` attribute for the code block has been specified,
  #   it gets passed to the `listings` package using the `lstset` macro.
  #   The default lang for code blocks is specified through
  #   the `code_lang` attribute.
  #
  #     \lstset{language=ruby}
  #
  #   Please refer to the documentation of the `listings` package for
  #   supported languages.
  #
  #   If a language is not supported, the `listings` package will emit
  #   a warning during the compilation. Just press enter and nothing
  #   wrong will happen.
  #
  # * If the `code_show_spaces` is specified, than spaces and tabs will
  #   be shown using the macro:
  #
  #     \lstset{showspaces=true,showtabs=true}
  #
  # * The background color is given by `code_background_color`.
  #
  #=end

  def to_latex_code
    if get_setting(:latex_use_listings)
      @doc.latex_require_package('listings')

      s = "\\lstset{columns=fixed,frame=shadowbox}"

      if get_setting(:code_show_spaces)
        s << "\\lstset{showspaces=true,showtabs=true}\n"
      else
        s << "\\lstset{showspaces=false,showtabs=false}\n"
      end

      color = latex_color get_setting(:code_background_color)

      s << "\\lstset{backgroundcolor=#{color}}\n"

      s << "\\lstset{basicstyle=\\ttfamily\\footnotesize}\n"


      lang = self.attributes[:lang] || @doc.attributes[:code_lang] || '{}'
      s << "\\lstset{language=#{lang}}\n" if lang

      "#{s}\n\\begin{lstlisting}\n#{self.raw_code}\n\\end{lstlisting}"
    else
      "\\begin{verbatim}#{self.raw_code}\\end{verbatim}\n"
    end
  end

  def to_latex_header
    header_levels = %w(section subsection subsubsection)
    h = header_levels[self.level - 1] || 'paragraph'

    title = children_to_latex
    if number = section_number
      title = number + title
    end

    if id = self.attributes[:id]
      # drop '#' at the beginning
      id = id[1..-1] if id.start_with? '#'
      %{\\hypertarget{%s}{}\\%s*{{%s}}\\label{%s}\n\n} % [ id, h, title, id ]
    else
      %{\\%s*{%s}\n\n} % [ h, title]
    end
  end

  def to_latex_ul
    if self.attributes[:toc]
      @doc.toc.to_latex
    else
      wrap_as_environment('itemize')
    end
  end

  def to_latex_quote
    wrap_as_environment('quote')
  end

  def to_latex_ol
    wrap_as_environment('enumerate')
  end

  def to_latex_li
    "\\item #{children_to_latex}\n"
  end

  def to_latex_strong
    "\\textbf{#{children_to_latex}}"
  end

  def to_latex_emphasis
    "\\emph{#{children_to_latex}}"
  end

  def wrap_as_span(c)
    "{#{c} #{children_to_latex}}"
  end

  def wrap_as_environment(name)
    "\\begin{#{name}}%
#{children_to_latex}
\\end{#{name}}\n"
  end

  SAFE_CHARS = Set.new(('a'..'z').to_a + ('A'..'Z').to_a)

  # the ultimate escaping
  # (is much better than using \verb)
  def latex_escape(source)
    source.chars.inject('') do |s, b|
      s << if b == '\\'
             '~'
           elsif SAFE_CHARS.include? b
             b
           else
             "\\char%d" % b[0].ord
           end
    end
  end

  def to_latex_entity
    entity_name = self.entity_name

    entity = MaRuKu::Out::EntityTable.instance.entity(entity_name)
    unless entity
      maruku_error "I don't know how to translate entity '#{entity_name}' to LaTeX."
      return ""
    end

    replace = entity.latex_string
    @doc.latex_require_package entity.latex_package if entity.latex_package

    if replace
      if replace.start_with?("\\") && !replace.end_with?('$', '}')
        replace + "{}"
      else
        replace
      end
    else
      tell_user "Cannot translate entity #{entity_name.inspect} to LaTeX."
      entity_name
    end
  end

  def to_latex_inline_code
    # Convert to printable latex chars
    s = latex_escape(self.raw_code)

    color = get_setting(:code_background_color)
    colorspec = latex_color(color, 'colorbox')

    "{#{colorspec}{\\tt #{s}}}"
  end

  def to_latex_immediate_link
    url = self.url
    text = url.gsub(/^mailto:/,'') # don't show mailto
    text = latex_escape(text)
    if url.start_with? '#'
      url = url[1..-1]
      "\\hyperlink{#{url}}{#{text}}"
    else
      "\\href{#{url}}{#{text}}"
    end
  end

  def to_latex_im_link
    url = self.url

    if url.start_with? '#'
      url = url[1..-1]
      "\\hyperlink{#{url}}{#{children_to_latex}}"
    else
      "\\href{#{url}}{#{children_to_latex}}"
    end
  end

  def to_latex_link
    id = self.ref_id || children_to_s
    ref = @doc.refs[sanitize_ref_id(id)] || @doc.refs[sanitize_ref_id(children_to_s)]
    if ref
      url = ref[:url]

      if url.start_with? '#'
        url = url[1..-1]
        "\\hyperlink{#{url}}{#{children_to_latex}}"
      else
        "\\href{#{url}}{#{children_to_latex}}"
      end
    else
      $stderr.puts "Could not find id = '#{id}'"
      children_to_latex
    end
  end

  def to_latex_email_address
    "\\href{mailto:#{self.email}}{#{latex_escape(self.email)}}"
  end

  def to_latex_table
    num_columns = self.align.size

    head, *rows = @children

    h = { :center => 'c' , :left => 'l' , :right => 'r'}
    align_string = self.align.map {|a| h[a] }.join('|')

    s = "\\begin{tabular}{#{align_string}}\n"

    s << array_to_latex(head, '&') + "\\\\" + "\n"

    s << "\\hline \n"

    rows.each do |row|
      s << array_to_latex(row, '&') + "\\\\" + "\n"
    end

    s << "\\end{tabular}"

    # puts table in its own paragraph
    s << "\n\n"
  end


  def to_latex_head_cell
    to_latex_cell
  end

  def to_latex_cell
    s=""
    if @attributes.has_key?(:colspan)
      # TODO figure out how to set the alignment (defaulting to left for now)
      s="\\multicolumn {"<< @attributes[:colspan]<<"}{|l|}{"<<children_to_latex<<"}"
    else
      children_to_latex
    end
  end

  def to_latex_footnote_reference
    id = self.footnote_id
    if f = @doc.footnotes[id]
      "\\footnote{#{f.children_to_latex.strip}} "
    else
      $stderr.puts "Could not find footnote '#{id}'"
    end
  end

  def to_latex_raw_html
    # Raw HTML removed in latex version
    ""
  end

  ## Definition lists ###
  def to_latex_definition_list
    s = "\\begin{description}\n"
    s << children_to_latex
    s << "\\end{description}\n"
  end

  def to_latex_definition
    s = ""

    self.terms.each do |t|
      s << "\n\\item[#{t.children_to_latex}] "
    end

    self.definitions.each do |d|
      s << "#{d.children_to_latex} \n"
    end

    s
  end

  def to_latex_abbr
    children_to_latex
  end

  def to_latex_image
    id = self.ref_id
    ref = @doc.refs[sanitize_ref_id(id)] || @doc.refs[sanitize_ref_id(children_to_s)]
    if ref
      url = ref[:url]
      $stderr.puts "Images not supported yet (#{url})"
      ""
    else
      maruku_error "Could not find ref #{id.inspect} for image.\n"+
        "Available are: #{@docs.refs.keys.inspect}"
      ""
    end
  end

  def to_latex_div
    type = self.attributes[:class]
    id = self.attributes[:id]
    case type
    when /^un_(\w*)/
      @children.shift
      s = "\\begin{u#{$1}}\n"
      s << children_to_latex
      s << "\\end{u#{$1}}\n"
    when /^num_(\w*)/
      @children.delete_at(0)
      s = "\\begin{#{$1}}"
      s << "\n\\label{#{id}}\\hypertarget{#{id}}{}\n"
      s << children_to_latex
      s << "\\end{#{$1}}\n"
    when /^proof/
      @children.delete_at(0)
      s = "\\begin{proof}\n"
      s << children_to_latex
      s << "\\end{proof}\n"
    else
      children_to_latex
    end
  end

  # Convert each child to html
  def children_to_latex
    array_to_latex(@children)
  end

  def array_to_latex(array, join_char='')
    e = []
    array.each do |c|
      if c.kind_of?(String)
        e << string_to_latex(c)
      else method = c.kind_of?(Maruku::MDElement) ? "to_latex_#{c.node_type}" : "to_latex"
        next unless c.respond_to?(method)

        h =  c.send(method)

        unless h
          raise "Nil latex for #{c.inspect} created with method #{method}"
        end

        if h.kind_of? Array
          e.concat h
        else
          e << h
        end
      end
    end
    e.join(join_char)
  end

  # These are TeX's special characters
  LATEX_ADD_SLASH = %w({ } $ & # _ %)

  # These, we transform to {\tt \char<ascii code>}
  LATEX_TO_CHARCODE = %w(^ ~ > <)

  # escapes special characters
  def string_to_latex(s)
    s = escape_to_latex(s)
    OtherGoodies.each do |k, v|
      s.gsub!(k, v)
    end
    s
  end

  # other things that are good on the eyes
  OtherGoodies = {
    /(\s)LaTeX/ => '\1\\LaTeX\\xspace ', # XXX not if already \LaTeX
  }

  private

  def escape_to_latex(s)
    s.chars.inject("") do |result, b|
      if LATEX_TO_CHARCODE.include? b
        result << "{\\tt \\symbol{#{b[0].ord}}}"
      elsif LATEX_ADD_SLASH.include? b
        result << '\\' << b
      elsif b == '\\'
        # there is no backslash in cmr10 fonts
        result << "$\\backslash$"
      else
        result << b
      end
    end
  end
end

module MaRuKu
  class MDDocument
    include MaRuKu::Out::Latex::MDDocumentExtensions
  end
end
