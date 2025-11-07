require 'maruku/output/to_html'

module MaRuKu
  class MDDocument
    def s5_theme
      xtext(self.attributes[:slide_theme] || "default")
    end

    # Render as an HTML fragment (no head, just the content of BODY). (returns a string)
    def to_s5(context={})
      content_only = context[:content_only] != false
      print_slides = context[:print_slides]

      if content_only
        body = xelem('div', doc)
      else
        html = xelem('html')
        html['xmlns'] = 'http://www.w3.org/1999/xhtml'
        html['xmlns:svg'] = "http://www.w3.org/2000/svg"
        html['xml:lang'] = self.attributes[:lang] || 'en'

        head = xelem('head')
        html << head

        me = xelem('meta')
        me['http-equiv'] = 'Content-type'
        me['content'] = 'text/html;charset=utf-8'
        head << me

        # Create title element
        doc_title = self.attributes[:title] || self.attributes[:subject] || ""
        begin
          title_content = MaRuKu::HTMLFragment.new(doc_title).to_html
        rescue
          title_content = xtext(doc_title)
        end
        title = xelem('title') << title_content
        head << title

        body = xelem('body')
        html << body
      end

      slide_header = self.attributes[:slide_header]
      slide_footer = self.attributes[:slide_footer]
      slide_subfooter = self.attributes[:slide_subfooter]
      slide_topleft  = self.attributes[:slide_topleft]
      slide_topright  = self.attributes[:slide_topright]
      slide_bottomleft  = self.attributes[:slide_bottomleft]
      slide_bottomright  = self.attributes[:slide_bottomright]

      dummy_layout_slide = "
    <div class='layout'>
    <div id='controls'> </div>
    <div id='currentSlide'> </div>
    <div id='header'> #{slide_header}</div>
    <div id='footer'>
    <h1>#{slide_footer}</h1>
    <h2>#{slide_subfooter}</h2>
    </div>
    <div class='topleft'> #{slide_topleft}</div>
    <div class='topright'> #{slide_topright}</div>
    <div class='bottomleft'> #{slide_bottomleft}</div>
    <div class='bottomright'> #{slide_bottomright}</div>
    </div>
                "
      body <<  dummy_layout_slide

      presentation = xelem('div')
      presentation['class'] = 'presentation'
      body << presentation

      first_slide = "
    <div class='slide'>
    <h1> #{self.attributes[:title] ||context[:title]}</h1>
    <h2> #{self.attributes[:subtitle] ||context[:subtitle]}</h2>
    <h3> #{self.attributes[:author] ||context[:author]}</h3>
    <h4> #{self.attributes[:company] ||context[:company]}</h4>
    </div>
    "
      presentation << first_slide

      slide_num = 0
      self.toc.section_children.each do |slide|
        slide_num += 1
        @doc.attributes[:doc_prefix] = "s#{slide_num}"

        div = xelem('div')
        presentation << div
        div['class'] = 'slide'

        h1 = xelem('h1')
        puts "Slide #{slide_num}: #{slide.header_element.children_to_html.join}" if print_slides
        slide.header_element.children_to_html.inject(h1, &:<<)
        div << h1

        array_to_html(slide.immediate_children).inject(div, &:<<)

        # render footnotes
        unless @doc.footnotes_order.empty?
          div << render_footnotes
          @doc.footnotes_order = []
        end
      end

      if content_only
        xml = body.to_html
      else
        head << S5_external

        add_css_to(head)

        xml = html.to_html
        Xhtml11_mathml2_svg11 + xml
      end
    end
  end
end
