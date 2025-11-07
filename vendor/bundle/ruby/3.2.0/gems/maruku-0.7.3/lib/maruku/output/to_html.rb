require 'maruku/string_utils'
require 'cgi'

# This module groups all functions related to HTML export.
module MaRuKu::Out::HTML

  # Escape text for use in HTML (content or attributes) by running it through
  # standard XML escaping (quotes and angle brackets and ampersands)
  def self.escapeHTML(text)
    CGI.escapeHTML(text)
    # TODO: When we drop Rubies < 1.9.3, re-add .gsub(/[^[:print:]\n\r\t]/, '') to
    # get rid of non-printable control characters.
  end

  # A simple class to represent an HTML element for output.
  class HTMLElement
    attr_accessor :name
    attr_accessor :attributes
    attr_accessor :children

    def initialize(name, attr={}, children=[])
      self.name = name
      self.attributes = attr || {}
      self.children = Array(children)
      children << yield if block_given?
    end

    def <<(child)
      children << child if children
      self
    end

    def [](key)
      attributes[key.to_s]
    end

    def []=(key, value)
      attributes[key.to_s] = value
    end

    def add_class(class_name)
      attributes['class'] = ((attributes['class']||'').split(' ') + [class_name]).join(' ')
    end

    # These elements have no children and should be rendered with a self-closing tag.
    # It's not an exhaustive list, but they cover everything we use.
    SELF_CLOSING = Set.new %w[br hr img link meta]

    def to_html
      m = "<#{name}"
      attributes.each do |k, v|
        m << " #{k.to_s}=\"#{v.to_s}\""
      end

      if SELF_CLOSING.include? name
        m << " />"
      else
        content = children.map(&:to_s)
        m << ">" << content.join('') << "</#{name}>"
      end
    end

    alias :to_str :to_html
    alias :to_s :to_html
  end

  # Render as an HTML fragment (no head, just the content of BODY). (returns a string)
  def to_html(context={})
    output = ""
    children_to_html.each do |e|
      output << e.to_s
    end

    # render footnotes
    unless @doc.footnotes_order.empty?
      output << render_footnotes
    end

    output
  end

  Xhtml11_mathml2_svg11 =
    '<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC
    "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"
    "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">
'

  # Render to a complete HTML document (returns a string)
  def to_html_document(context={})
    doc = to_html_document_tree

    xml = doc.to_s
    Xhtml11_mathml2_svg11 + xml
  end

  # Helper to create a text node
  def xtext(text)
    MaRuKu::Out::HTML.escapeHTML(text)
  end

  # Helper to create an element
  def xelem(type)
    HTMLElement.new(type)
  end

  def xml_newline
    "\n"
  end

  #=begin maruku_doc
  # Attribute: title
  # Scope: document
  #
  # Sets the title of the document.
  # If a title is not specified, the first header will be used.
  #
  # These should be equivalent:
  #
  #   Title: my document
  #
  #   Content
  #
  # and
  #
  #   my document
  #   ===========
  #
  #   Content
  #
  # In both cases, the title is set to "my document".
  #=end

  #=begin maruku_doc
  # Attribute: doc_prefix
  # Scope: document
  #
  # String to disambiguate footnote links.
  #=end


  #=begin maruku_doc
  # Attribute: subject
  # Scope: document

  # Synonym for `title`.
  #=end

  #=begin maruku_doc
  # Attribute: css
  # Scope: document
  # Output: HTML
  # Summary: Activates CSS stylesheets for HTML.
  #
  # `css` should be a space-separated list of urls.
  #
  # Example:
  #
  #   CSS: style.css math.css
  #
  #=end

  # Render to a complete HTML document (returns an HTMLElement document tree)
  def to_html_document_tree
    root = xelem('html')
    root['xmlns'] = 'http://www.w3.org/1999/xhtml'
    root['xmlns:svg'] = "http://www.w3.org/2000/svg"
    root['xml:lang'] = self.attributes[:lang] || 'en'

    root << xml_newline
    head = xelem('head')
    root << head

    #<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8">
    me = xelem('meta')
    me['http-equiv'] = 'Content-type'
    me['content'] = 'application/xhtml+xml;charset=utf-8'
    head << me

    %w(description keywords author revised).each do |m|
      if value = self.attributes[m.to_sym]
        meta = xelem('meta')
        meta['name'] = m
        meta['content'] = value.to_s
        head << meta
      end
    end

    self.attributes.each do |k,v|
      if k.to_s =~ /\Ameta-(.*)\z/
        meta = xelem('meta')
        meta['name'] = $1
        meta['content'] = v.to_s
        head << meta
      end
    end

    # Create title element
    doc_title = self.attributes[:title] || self.attributes[:subject] || ""
    begin
      title_content = MaRuKu::HTMLFragment.new(doc_title).to_html
    rescue
      title_content = xtext(doc_title)
    end
    title = xelem('title') << title_content
    head << title
    add_css_to(head)

    root << xml_newline

    body = xelem('body')

    children_to_html.each do |e|
      body << e.to_s
    end

    # render footnotes
    unless @doc.footnotes_order.empty?
      body << render_footnotes
    end

    # When we are rendering a whole document, we add a signature
    # at the bottom.
    if get_setting(:maruku_signature)
      body << maruku_html_signature
    end

    root << body
  end

  def add_css_to(head)
    if css_list = self.attributes[:css]
      css_list.split.each do |css|
        # <link type="text/css" rel="stylesheet" href="..." />
        link = xelem('link')
        link['type'] = 'text/css'
        link['rel'] = 'stylesheet'
        link['href'] = css
        head << link << xml_newline
      end
    end
  end

  # returns "st","nd","rd" or "th" as appropriate
  def day_suffix(day)
    s = {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      21 => 'st',
      22 => 'nd',
      23 => 'rd',
      31 => 'st'
    }
    s[day] || 'th';
  end

  # formats a nice date
  def nice_date
    Time.now.strftime(" at %H:%M on %A, %B %d") +
      day_suffix(t.day) +
      t.strftime(", %Y")
  end

  def maruku_html_signature
    div = xelem('div')
    div['class'] = 'maruku_signature'
    div << xelem('hr')
    span = xelem('span')
    span['style'] = 'font-size: small; font-style: italic'
    div << span << xtext('Created by ')
    a = xelem('a')
    a['href'] = MaRuKu::MARUKU_URL
    a['title'] = 'Maruku: a Markdown-superset interpreter for Ruby'
    a << xtext('Maruku')
    span << xtext(nice_date + ".")
    div
  end

  def render_footnotes
    div = xelem('div')
    div['class'] = 'footnotes'
    div << xelem('hr')
    ol = xelem('ol')

    @doc.footnotes_order.each_with_index do |fid, i|
      num = i + 1
      if f = self.footnotes[fid]
        li = f.wrap_as_element('li')
        li['id'] = "#{get_setting(:doc_prefix)}fn:#{num}"

        a = xelem('a')
        a['href'] = "\##{get_setting(:doc_prefix)}fnref:#{num}"
        a['rev'] = 'footnote'
        a << xtext([8617].pack('U*'))

        last = nil
        li.children.reverse_each do |child|
          if child.is_a?(HTMLElement)
            last = child
            break
          end
        end

        if last && last.name == "p"
          last << xtext(' ') << a
        else
          li.children << a
        end
        ol << li
      else
        maruku_error "Could not find footnote id '#{fid}' among [#{self.footnotes.keys.inspect}]."
      end
    end

    div << ol
  end

  def to_html_hrule
    xelem('hr')
  end

  def to_html_linebreak
    xelem('br')
  end

  # renders children as html and wraps into an element of given name
  #
  # Sets 'id' if meta is set
  def wrap_as_element(name, attributes={})
    html_element name, children_to_html, attributes
  end

  #=begin maruku_doc
  # Attribute: id
  # Scope: element
  # Output: LaTeX, HTML
  #
  # It is copied as a standard HTML attribute.
  #
  # Moreover, it used as a label name for hyperlinks in both HTML and
  # in PDF.
  #=end

  #=begin maruku_doc
  # Attribute: class
  # Scope: element
  # Output: HTML
  #
  # It is copied as a standard HTML attribute.
  #=end

  #=begin maruku_doc
  # Attribute: style
  # Scope: element
  # Output: HTML
  #
  # It is copied as a standard HTML attribute.
  #=end

  HTML4Attributes = {}

  coreattrs = [:id, :class, :style, :title, :accesskey, :contenteditable, :dir,
               :draggable, :spellcheck, :tabindex]
  i18n = [:lang, :'xml:lang']
  events = [:onclick, :ondblclick, :onmousedown, :onmouseup, :onmouseover,
            :onmousemove, :onmouseout,
            :onkeypress, :onkeydown, :onkeyup]
  common_attrs = coreattrs + i18n + events
  cells = [:align, :char, :charoff, :valign]

  # Each row maps a list of tags to the list of attributes beyond the common_attributes
  # that are valid on those elements
  [
   ['body', [:onload, :onunload]],
   ['a', [:charset, :type, :name, :rel, :rev, :accesskey, :shape, :coords, :tabindex,
          :onfocus,:onblur]],
   ['img', [:longdesc, :name, :height, :width, :alt]],
   ['ol', [:reversed, :start]],
   ['li', [:value]],
   ['table', [:summary, :width, :frame, :rules, :border, :cellspacing, :cellpadding]],
   [%w(q blockquote), [:cite]],
   [%w(ins del), [:cite, :datetime]],
   [%w(colgroup col), [:span, :width] + cells],
   [%w(thead tbody tfoot), cells],
   [%w(td td th), [:abbr, :axis, :headers, :scope, :rowspan, :colspan] + cells],
   [%w(em code strong hr span dl dd dt address div p pre caption ul h1 h2 h3 h4 h5 h6), []]
  ].each do |elements, attributes|
    [*elements].each do |element|
      HTML4Attributes[element] = common_attrs + attributes
    end
  end

  # Pretty much the same as the HTMLElement constructor except it
  # copies standard attributes out of the Maruku Element's attributes hash.
  def html_element(name, content="", attributes={})
    attributes = content if attributes.empty? && content.is_a?(Hash)

    Array(HTML4Attributes[name]).each do |att|
      if v = @attributes[att]
        attributes[att.to_s] = MaRuKu::Out::HTML.escapeHTML(v.to_s)
      end
    end

    content = yield if block_given?

    HTMLElement.new(name, attributes, content)
  end

  def to_html_ul
    if @attributes[:toc]
      # render toc
      @doc.toc.to_html
    else
      add_ws wrap_as_element('ul')
    end
  end

  def to_html_paragraph
    add_ws wrap_as_element('p')
  end

  def to_html_ol
    add_ws wrap_as_element('ol')
  end

  def to_html_li
    add_ws wrap_as_element('li')
  end

  def to_html_quote
    add_ws wrap_as_element('blockquote')
  end

  def to_html_strong
    wrap_as_element('strong')
  end

  def to_html_emphasis
    wrap_as_element('em')
  end

  #=begin maruku_doc
  # Attribute: use_numbered_headers
  # Scope: document
  # Summary: Activates the numbering of headers.
  #
  # If `true`, section headers will be numbered.
  #
  # In LaTeX export, the numbering of headers is managed
  # by Maruku, to have the same results in both HTML and LaTeX.
  #=end

  # nil if not applicable, else string
  def section_number
    return nil unless get_setting(:use_numbered_headers)

    n = Array(@attributes[:section_number])
    return nil if n.empty?

    n.join('.') + ". "
  end

  # nil if not applicable, else SPAN element
  def render_section_number
    return nil unless section_number && !section_number.empty?

    # if we are bound to a section, add section number
    span = xelem('span')
    span['class'] = 'maruku_section_number'
    span << xtext(section_number)
  end

  def to_html_header
    element_name = "h#{self.level}"
    h = wrap_as_element element_name

    if span = render_section_number
      h.children.unshift(span)
    end

    add_ws h
  end

  #=begin maruku_doc
  # Attribute: html_use_syntax
  # Scope: global, document, element
  # Output: HTML
  # Summary: Enables the use of the `syntax` package.
  # Related: lang, code_lang
  # Default: <?mrk md_code(Globals[:html_use_syntax].to_s) ?>
  #
  # If true, the `syntax` package is used. It supports the `ruby` and `xml`
  # languages. Remember to set the `lang` attribute of the code block.
  #
  # Examples:
  #
  #     require 'maruku'
  #   {:lang=ruby html_use_syntax=true}
  #
  # and
  #
  #     <div style="text-align:center">Div</div>
  #   {:lang=html html_use_syntax=true}
  #
  # produces:
  #
  #   require 'maruku'
  # {:lang=ruby html_use_syntax=true}
  #
  # and
  #
  #   <div style="text-align:center">Div</div>
  # {:lang=html html_use_syntax=true}
  #
  #=end

  $syntax_loaded = false
  def to_html_code
    source = self.raw_code

    code_lang = self.lang || self.attributes[:lang] || @doc.attributes[:code_lang]

    code_lang = 'xml' if code_lang == 'html'
    code_lang = 'css21' if code_lang == 'css'

    use_syntax = get_setting :html_use_syntax

    element =
      if use_syntax && code_lang
        begin
          unless $syntax_loaded
            require 'rubygems'
            require 'syntax'
            require 'syntax/convertors/html'
            $syntax_loaded = true
          end
          convertor = Syntax::Convertors::HTML.for_syntax code_lang

          # eliminate trailing newlines otherwise Syntax crashes
          source = source.sub(/\n*\z/, '')

          html = convertor.convert(source)

          html.gsub!(/\&apos;|'/,'&#39;') # IE bug

          d = MaRuKu::HTMLFragment.new(html)
          highlighted = d.to_html.sub(/\A<pre>(.*)<\/pre>\z/m, '\1')
          code = HTMLElement.new('code', { :class => code_lang }, highlighted)

          pre = xelem('pre')
          # add a class here, too, for compatibility with existing implementations
          pre['class'] = code_lang
          pre << code
          pre
        rescue LoadError => e
          maruku_error "Could not load package 'syntax'.\n" +
            "Please install it, for example using 'gem install syntax'."
          to_html_code_using_pre(source, code_lang)
        rescue => e
          maruku_error "Error while using the syntax library for code:\n#{source.inspect}" +
            "Lang is #{code_lang} object is: \n" +
            self.inspect +
            "\nException: #{e.class}: #{e.message}"

          tell_user("Using normal PRE because the syntax library did not work.")
          to_html_code_using_pre(source, code_lang)
        end
      else
        to_html_code_using_pre(source, code_lang)
      end

    color = get_setting(:code_background_color)
    if color != MaRuKu::Globals[:code_background_color]
      element['style'] = "background-color: #{color};"
    end

    add_ws element
  end

  #=begin maruku_doc
  # Attribute: code_background_color
  # Scope: global, document, element
  # Summary: Background color for code blocks.
  #
  # The format is either a named color (`green`, `red`) or a CSS color
  # of the form `#ff00ff`.
  #
  # * for **HTML output**, the value is put straight in the `background-color` CSS
  #   property of the block.
  #
  # * for **LaTeX output**, if it is a named color, it must be a color accepted
  #   by the LaTeX `color` packages. If it is of the form `#ff00ff`, Maruku
  #   defines a color using the `\color[rgb]{r,g,b}` macro.
  #
  #   For example, for `#0000ff`, the macro is called as: `\color[rgb]{0,0,1}`.
  #=end


  def to_html_code_using_pre(source, code_lang=nil)
    code = xelem('code')
    pre = xelem('pre')
    pre << code

    if get_setting(:code_show_spaces)
      # 187 = raquo
      # 160 = nbsp
      # 172 = not
      source = source.gsub(/\t/,'&#187;' + '&#160;' * 3).gsub(/ /,'&#172;')
    end

    code << xtext(source)

    code_lang ||= self.attributes[:lang]
    if code_lang
      pre['class'] = code['class'] = code_lang
    end

    pre
  end

  def to_html_inline_code
    code_attrs = {}
    source = xtext(self.raw_code)

    color = get_setting(:code_background_color)
    if color != MaRuKu::Globals[:code_background_color]
      code_attrs['style'] = "background-color: #{color};" + (code_attrs['style'] || "")
    end

    html_element('code', source, code_attrs)
  end

  def add_class_to(el, cl)
    el['class'] =
      if already = el['class']
        already + " " + cl
      else
        cl
      end
  end

  def to_html_immediate_link
    text = self.url.gsub(/^mailto:/, '') # don't show mailto
    html_element('a', text, 'href' => self.url)
  end

  def to_html_link
    a = {}
    id = self.ref_id || children_to_s

    if ref = @doc.refs[sanitize_ref_id(id)] || @doc.refs[sanitize_ref_id(children_to_s)]
      a['href'] = ref[:url] if ref[:url]
      a['title'] = ref[:title] if ref[:title]
    else
      maruku_error "Could not find ref_id = #{id.inspect} for #{self.inspect}\n" +
        "Available refs are #{@doc.refs.keys.inspect}"
      tell_user "Not creating a link for ref_id = #{id.inspect}.\n"
      if (self.ref_id)
        return "[#{children_to_s}][#{id}]"
      else
        return "[#{children_to_s}]"
      end
    end

    wrap_as_element('a', a)
  end

  def to_html_im_link
    if self.url
      a = {}
      a['href'] = self.url
      a['title'] = self.title if self.title
      wrap_as_element('a', a)
    else
      maruku_error "Could not find url in #{self.inspect}"
      tell_user "Not creating a link for ref_id = #{id.inspect}."
      wrap_as_element('span')
    end
  end

  def add_ws(e)
    [xml_newline, e, xml_newline]
  end

  ##### Email address

  def obfuscate(s)
    s.bytes.inject('') do |res, char|
      res << "&#%03d;" % char
    end
  end

  def to_html_email_address
    obfuscated = obfuscate(self.email)
    html_element('a', obfuscated, :href => "mailto:#{obfuscated}")
  end

  ##### Images

  def to_html_image
    a = {}
    id = self.ref_id
    if ref = @doc.refs[sanitize_ref_id(id)] || @doc.refs[sanitize_ref_id(children_to_s)]
      a['src'] = ref[:url].to_s
      a['alt'] = children_to_s
      a['title'] = ref[:title].to_s if ref[:title]
      html_element('img', nil, a)
    else
      maruku_error "Could not find id = #{id.inspect} for\n #{self.inspect}"
      tell_user "Could not create image with ref_id = #{id.inspect};" +
        " Using SPAN element as replacement."
      wrap_as_element('span')
    end
  end

  def to_html_im_image
    if self.url
      attrs = {}
      attrs['src'] = self.url.to_s
      attrs['alt'] = children_to_s
      attrs['title'] = self.title.to_s if self.title
      html_element('img', nil, attrs)
    else
      maruku_error "Image with no url: #{self.inspect}"
      tell_user "Could not create image without a source URL;" +
        " Using SPAN element as replacement."
      wrap_as_element('span')
    end
  end

  #=begin maruku_doc
  # Attribute: filter_html
  # Scope: document
  #
  # If true, raw HTML is discarded from the output.
  #
  #=end

  def to_html_raw_html
    return [] if get_setting(:filter_html)
    return parsed_html.to_html if parsed_html

    # If there's no parsed HTML
    raw_html = self.raw_html

    # Creates red box with offending HTML
    tell_user "Wrapping bad html in a PRE with class 'markdown-html-error'\n" +
      raw_html.gsub(/^/, '|')
    pre = xelem('pre')
    pre['style'] = 'border: solid 3px red; background-color: pink'
    pre['class'] = 'markdown-html-error'
    pre << xtext("Maruku could not parse this XML/HTML: \n#{raw_html}")
  end

  def to_html_abbr
    abbr = xelem('abbr')
    abbr << xtext(children[0])
    abbr['title'] = self.title if self.title
    abbr
  end

  def to_html_footnote_reference
    id = self.footnote_id

    # save the order of used footnotes
    order = @doc.footnotes_order

    # footnote has already been used
    return [] if order.include?(id)

    return [] unless @doc.footnotes[id]

    # take next number
    order << id

    num = order.index(id) + 1

    sup = xelem('sup')
    sup['id'] = "#{get_setting(:doc_prefix)}fnref:#{num}"
    a = xelem('a')
    a << xtext(num.to_s)
    a['href'] = "\##{get_setting(:doc_prefix)}fn:#{num}"
    a['rel'] = 'footnote'
    sup << a
  end

  ## Definition lists ###
  def to_html_definition_list
    add_ws wrap_as_element('dl')
  end

  def to_html_definition
    children_to_html
  end

  def to_html_definition_term
    add_ws wrap_as_element('dt')
  end

  def to_html_definition_data
    add_ws wrap_as_element('dd')
  end

  def to_html_table
    num_columns = self.align.size

    # The table data is passed as a multi-dimensional array
    # we just need to split the head from the body
    head, *rows = @children

    table = html_element('table')
    thead = xelem('thead')
    tr = xelem('tr')
    array_to_html(head).inject(tr, &:<<)
    thead << tr
    table << thead

    tbody = xelem('tbody')
    rows.each do |row|
      tr = xelem('tr')
      array_to_html(row).each_with_index do |x, i|
        x['style'] ="text-align: #{self.align[i].to_s};"
        tr << x
      end

      tbody << tr << xml_newline
    end

    table << tbody
  end

  def to_html_head_cell
    wrap_as_element('th')
  end

  def to_html_cell
    if @attributes[:scope]
      wrap_as_element('th')
    else
      wrap_as_element('td')
    end
  end

  def to_html_entity
    entity_name = self.entity_name

    if entity = MaRuKu::Out::EntityTable.instance.entity(entity_name)
      entity_name = entity.html_num
    end

    if entity_name.kind_of? Integer
      # Convert numeric entities to unicode characters
      xtext([entity_name].pack('U*'))
    else
      "&#{entity_name};"
    end
  end

  def to_html_xml_instr
    target = self.target || ''
    code = self.code || ''

    # A blank target is invalid XML. Just create a text node?
    if target.empty?
      xtext("<?#{code}?>")
    else
      "<?#{target} #{code}?>"
    end
  end

  # Convert each child to html
  def children_to_html
    array_to_html(@children)
  end

  def array_to_html(array)
    e = []
    array.each do |c|
      if c.kind_of?(String)
        e << xtext(c)
      else
        if c.kind_of?(HTMLElement)
          e << c
          next
        end

        method = c.kind_of?(MaRuKu::MDElement) ? "to_html_#{c.node_type}" : "to_html"
        next unless c.respond_to?(method)

        h = c.send(method)

        unless h
          raise "Nil html created by method  #{method}:\n#{h.inspect}\n" +
            " for object #{c.inspect[0,300]}"
        end

        if h.kind_of? Array
          e.concat h
        else
          e << h
        end
      end
    end
    e
  end

  def to_html_ref_definition
    []
  end

  def to_latex_ref_definition
    []
  end
end
