require 'maruku/html'

module MaRuKu
  # A collection of helper functions for creating Markdown elements.
  # They hide the particular internal representations.
  #
  # Always use these rather than creating an {MDElement} directly.
  module Helpers
    # @param children [MDElement, String, Array<MDElement, String>]
    #   The child nodes.
    #   If the first child is a \{#md\_ial}, it's merged with `al`
    def md_el(node_type, children=[], meta={}, al=nil)
      children = Array(children)

      first = children.first
      if first && first.is_a?(MDElement) && first.node_type == :ial
        if al
          al += first.ial
        else
          al = first.ial
        end
        children.shift
      end

      e = MDElement.new(node_type, children, meta, al)
      e.doc = @doc
      e
    end

    def md_header(level, children, al=nil)
      md_el(:header, children, { :level => level }, al)
    end

    # Inline code
    def md_code(code, al=nil)
      md_el(:inline_code, [], { :raw_code => code }, al)
    end

    # Code block
    def md_codeblock(source, lang=nil, al=nil)
      md_el(:code, [], { :raw_code => source, :lang => lang }, al)
    end

    def md_quote(children, al=nil)
      md_el(:quote, children, {}, al)
    end

    def md_li(children, want_my_par=false, al=nil)
      md_el(:li, children, { :want_my_paragraph => want_my_par }, al)
    end

    def md_footnote(footnote_id, children, al=nil)
      md_el(:footnote, children, { :footnote_id => footnote_id }, al)
    end

    def md_abbr_def(abbr, text, al=nil)
      md_el(:abbr_def, [], { :abbr => abbr, :text => text }, al)
    end

    def md_abbr(abbr, title)
      md_el(:abbr, abbr, :title => title)
    end

    def md_html(raw_html, al=nil)
      e = MDHTMLElement.new(:raw_html, [], :raw_html => raw_html)
      e.doc = @doc
      begin
        # Set this as an attribute so it doesn't get included
        # in metadata comparisons
        e.parsed_html = MaRuKu::HTMLFragment.new(raw_html)
      rescue => ex
        maruku_recover "Maruku cannot parse this block of HTML/XML:\n" +
          raw_html.gsub(/^/, '|').rstrip + "\n" + ex.to_s
      end
      e
    end

    def md_link(children, ref_id, al=nil)
      md_el(:link, children, { :ref_id => ref_id }, al)
    end

    def md_im_link(children, url, title = nil, al=nil)
      md_el(:im_link, children, { :url => url, :title => title }, al)
    end

    def md_image(children, ref_id, al=nil)
      md_el(:image, children, { :ref_id => ref_id }, al)
    end

    def md_im_image(children, url, title=nil, al=nil)
      md_el(:im_image, children, { :url => url, :title => title }, al)
    end

    def md_em(children, al=nil)
      md_el(:emphasis, children, {}, al)
    end

    def md_br
      md_el(:linebreak, [], {}, nil)
    end

    def md_hrule
      md_el(:hrule, [], {}, nil)
    end

    def md_strong(children, al=nil)
      md_el(:strong, children, {}, al)
    end

    def md_emstrong(children, al=nil)
      md_strong(md_em(children), al)
    end

    # A URL to be linkified (e.g. `<http://www.example.com/>`).
    def md_url(url, al=nil)
      md_el(:immediate_link, [], { :url => url }, al)
    end

    # An email to be linkified
    # (e.g. `<andrea@rubyforge.org>` or `<mailto:andrea@rubyforge.org>`).
    def md_email(email, al=nil)
      md_el(:email_address, [], { :email => email }, al)
    end

    def md_entity(entity_name, al=nil)
      md_el(:entity, [], { :entity_name => entity_name }, al)
    end

    # Markdown extra
    def md_foot_ref(ref_id, al=nil)
      md_el(:footnote_reference, [], { :footnote_id => ref_id }, al)
    end

    def md_par(children, al=nil)
      md_el(:paragraph, children, {}, al)
    end

    # A definition of a reference (e.g. `[1]: http://url [properties]`).
    def md_ref_def(ref_id, url, title=nil, meta={}, al=nil)
      all_meta = meta.merge({ :url => url, :ref_id => ref_id })
      all_meta[:title] ||= title
      md_el(:ref_definition, [], all_meta, al)
    end

    # inline attribute list
    def md_ial(al)
      al = Maruku::AttributeList.new(al) unless al.is_a?(Maruku::AttributeList)
      md_el(:ial, [], :ial => al)
    end

    # Attribute list definition
    def md_ald(id, al)
      md_el(:ald, [], :ald_id => id, :ald => al)
    end

    # A server directive (e.g. `<?target code... ?>`)
    def md_xml_instr(target, code)
      md_el(:xml_instr, [], :target => target, :code => code)
    end
  end
end
