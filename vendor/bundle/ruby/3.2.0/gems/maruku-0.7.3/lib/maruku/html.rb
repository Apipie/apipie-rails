require 'set'

$warned_nokogiri = false

module MaRuKu
  HTML_INLINE_ELEMS = Set.new %w[a abbr acronym audio b bdi bdo big br button canvas caption cite code
    col colgroup command datalist del details dfn dir em fieldset font form i img input ins
    kbd label legend mark meter optgroup option progress q rp rt ruby s samp select small
    source span strike strong sub summary sup tbody td tfoot th thead time tr track tt u var video wbr
    animate animateColor animateMotion animateTransform circle clipPath defs desc ellipse
    feGaussianBlur filter font-face font-face-name font-face-src foreignObject g glyph hkern
    linearGradient line marker mask metadata missing-glyph mpath path pattern polygon polyline
    radialGradient rect set stop svg switch text textPath title tspan use
    annotation annotation-xml maction math menclose merror mfrac mfenced mi mmultiscripts mn mo
    mover mpadded mphantom mprescripts mroot mrow mspace msqrt mstyle msub msubsup msup mtable
    mtd mtext mtr munder munderover none semantics]

  # Parse block-level markdown elements in these HTML tags
  BLOCK_TAGS = Set.new %w[div section]

  # This gets mixed into HTML MDElement nodes to hold the parsed document fragment
  module HTMLElement
    attr_accessor :parsed_html
  end

  # This is just a factory, not an actual class
  module HTMLFragment

    # HTMLFragment.new produces a concrete HTMLFragment implementation
    # that is either a NokogiriHTMLFragment or a REXMLHTMLFragment.
    def self.new(raw_html)
      if !$warned_nokogiri && MaRuKu::Globals[:html_parser] == 'nokogiri'
        begin
          require 'nokogiri'
          return NokogiriHTMLFragment.new(raw_html)
        rescue LoadError
          warn "Nokogiri could not be loaded. Falling back to REXML."
          $warned_nokogiri = true
        end
      end

      require 'rexml/document'
      REXMLHTMLFragment.new(raw_html)
    end
  end

  # Nokogiri backend for HTML handling
  class NokogiriHTMLFragment
    def initialize(raw_html)
      # Wrap our HTML in a dummy document with a doctype (just
      # for the entity references)
      wrapped = '<!DOCTYPE html PUBLIC
  "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"
  "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">
<html>' + raw_html.strip + '</html>'

      d = Nokogiri::XML::Document.parse(wrapped) {|c| c.nonet }
      @fragment = d.root
    end

    # @return The name of the first child element in the fragment.
    def first_node_name
      first_child = @fragment.children.first
      first_child ? first_child.name : nil
    end

    # Add a class to the children of this fragment
    def add_class(class_name)
      @fragment.children.each do |c|
        c['class'] = ((c['class']||'').split(' ') + [class_name]).join(' ')
      end
    end

    # Process markdown within the contents of some elements and
    # replace their contents with the processed version.
    #
    # @param doc [MaRuKu::MDDocument] A document to process.
    def process_markdown_inside_elements(doc)
      # find span elements or elements with 'markdown' attribute
      elts = @fragment.css("[markdown]")

      d = @fragment.children.first
      if d && HTML_INLINE_ELEMS.include?(d.name)
        elts << d unless d.attribute('markdown')
        elts += span_descendents(d)
      end

      elts.each do |e|
        how = e['markdown']
        e.remove_attribute('markdown')

        next if "0" == how # user requests no markdown parsing inside
        parse_blocks = (how == 'block') || BLOCK_TAGS.include?(e.name)

        # Select all text children of e
        e.xpath("./text()").each do |original_text|
          s = MaRuKu::Out::HTML.escapeHTML(original_text.text)
          unless s.strip.empty?
            parsed = parse_blocks ? doc.parse_text_as_markdown(s) : doc.parse_span(s)

            # restore leading and trailing spaces
            padding = /\A(\s*).*?(\s*)\z/.match(s)
            parsed = [padding[1]] + parsed + [padding[2]] if padding

            el = doc.md_el(:dummy, parsed)

            # Nokogiri collapses consecutive Text nodes, so replace it by a dummy element
            guard = Nokogiri::XML::Element.new('guard', @fragment)
            original_text.replace(guard)
            el.children_to_html.each do |x|
              guard.before(x.to_s)
            end
            guard.remove
          end
        end
      end
    end

    # Convert this fragment to an HTML or XHTML string.
    # @return [String]
    def to_html
      output_options = Nokogiri::XML::Node::SaveOptions::DEFAULT_XHTML ^
        Nokogiri::XML::Node::SaveOptions::FORMAT
      @fragment.children.inject("") do |out, child|
        out << child.serialize(:save_with => output_options, :encoding => 'UTF-8')
      end
    end

    private

    # Get all span-level descendents of the given element, recursively,
    # as a flat NodeSet.
    #
    # @param e [Nokogiri::XML::Node] An element.
    # @return [Nokogiri::XML::NodeSet]
    def span_descendents(e)
      ns = Nokogiri::XML::NodeSet.new(Nokogiri::XML::Document.new)
      e.element_children.inject(ns) do |descendents, c|
        if HTML_INLINE_ELEMS.include?(c.name)
          descendents << c
          descendents += span_descendents(c)
        end
        descendents
      end
    end
  end

  # An HTMLFragment implementation using REXML
  class REXMLHTMLFragment
    def initialize(raw_html)
      wrapped = '<!DOCTYPE html PUBLIC
  "-//W3C//DTD XHTML 1.1 plus MathML 2.0 plus SVG 1.1//EN"
  "http://www.w3.org/2002/04/xhtml-math-svg/xhtml-math-svg.dtd">
<html>' + raw_html.strip + '</html>'

      @fragment = REXML::Document.new(wrapped).root
    end

    # The name of the first element in the fragment
    def first_node_name
      first_child = @fragment.children.first
      (first_child && first_child.respond_to?(:name)) ? first_child.name : nil
    end

    # Add a class to the children of this fragment
    def add_class(class_name)
      @fragment.each_element do |c|
        c.attributes['class'] = ((c.attributes['class']||'').split(' ') + [class_name]).join(' ')
      end
    end

    # Process markdown within the contents of some elements and
    # replace their contents with the processed version.
    def process_markdown_inside_elements(doc)
      elts = []
      @fragment.each_element('//*[@markdown]') do |e|
        elts << e
      end

      d = @fragment.children.first
      if d && HTML_INLINE_ELEMS.include?(first_node_name)
        elts << d unless d.attributes['markdown']
        elts += span_descendents(d)
      end

      # find span elements or elements with 'markdown' attribute
      elts.each do |e|
        # should we parse block-level or span-level?
        how = e.attributes['markdown']
        e.attributes.delete('markdown')

        next if "0" == how # user requests no markdown parsing inside
        parse_blocks = (how == 'block') || BLOCK_TAGS.include?(e.name)

        # Select all text children of e
        e.texts.each do |original_text|
          s = MaRuKu::Out::HTML.escapeHTML(original_text.value)
          unless s.strip.empty?
            # TODO extract common functionality
            parsed = parse_blocks ? doc.parse_text_as_markdown(s) : doc.parse_span(s)
            # restore leading and trailing spaces
            padding = /\A(\s*).*?(\s*)\z/.match(s)
            parsed = [padding[1]] + parsed + [padding[2]] if padding

            el = doc.md_el(:dummy, parsed)

            new_html = "<dummy>"
            el.children_to_html.each do |x|
              new_html << x.to_s
            end
            new_html << "</dummy>"

            newdoc = REXML::Document.new(new_html).root

            p = original_text.parent
            newdoc.children.each do |c|
              p.insert_before(original_text, c)
            end

            p.delete(original_text)
          end
        end
      end
    end

    def to_html
      formatter = REXML::Formatters::Default.new(true)
      @fragment.children.inject("") do |out, child|
        out << formatter.write(child, '')
      end
    end

    private

    # Get all span-level descendents of the given element, recursively,
    # as an Array.
    #
    # @param e [REXML::Element] An element.
    # @return [Array]
    def span_descendents(e)
      descendents = []
      e.each_element do |c|
        name = c.respond_to?(:name) ? c.name : nil
        if name && HTML_INLINE_ELEMS.include?(c.name)
          descendents << c
          descendents += span_descendents(c)
        end
      end
    end
  end
end
