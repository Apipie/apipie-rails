#=begin maruku_doc
# Extension: math
# Attribute: html_math_engine
# Scope: document, element
# Output: html
# Summary: Select the rendering engine for MathML.
# Default: <?mrk Globals[:html_math_engine].to_s ?>
#
# Select the rendering engine for math.
#
# If you want to use your custom engine `foo`, then set:
#
#   HTML math engine: foo
# {:lang=markdown}
#
# and then implement two functions:
#
#   def convert_to_mathml_foo(kind, tex)
#     ...
#   end
#=end

#=begin maruku_doc
# Extension: math
# Attribute: html_png_engine
# Scope: document, element
# Output: html
# Summary: Select the rendering engine for math.
# Default: <?mrk Globals[:html_math_engine].to_s ?>
#
# Same thing as `html_math_engine`, only for PNG output.
#
#   def convert_to_png_foo(kind, tex)
#     # same thing
#     ...
#   end
# {:lang=ruby}
#
#=end

module MaRuKu
  module Out
    module HTML
      # Creates an xml Mathml document of this node's TeX code.
      #
      # @return [MaRuKu::Out::HTML::HTMLElement]
      def render_mathml(kind, tex)
        engine = get_setting(:html_math_engine)
        method = "convert_to_mathml_#{engine}"
        if self.respond_to? method
          mathml = self.send(method, kind, tex)
          return mathml || convert_to_mathml_none(kind, tex)
        end

        # TODO: Warn here
        raise "A method called #{method} should be defined."
        convert_to_mathml_none(kind, tex)
      end

      # Renders a PNG image of this node's TeX code.
      # Returns
      #
      # @return [MaRuKu::Out::HTML::PNG, nil]
      #   A struct describing the location and size of the image,
      #   or nil if no library is loaded that can render PNGs.
      def render_png(kind, tex)
        engine = get_setting(:html_png_engine)
        method = "convert_to_png_#{engine}".to_sym
        return self.send(method, kind, tex) if self.respond_to? method

        raise "A method called #{method} should be defined."
        nil
      end

      def pixels_per_ex
        $pixels_per_ex ||= render_png(:inline, "x").height
      end

      def adjust_png(png, use_depth)
        src = png.src

        height_in_px = png.height
        depth_in_px = png.depth
        height_in_ex = height_in_px / pixels_per_ex
        depth_in_ex = depth_in_px / pixels_per_ex
        total_height_in_ex = height_in_ex + depth_in_ex
        style = ""
        style << "vertical-align: -#{depth_in_ex}ex;" if use_depth
        style << "height: #{total_height_in_ex}ex;"

        img = xelem('img')
        img['src'] = src
        img['style'] = style
        img['alt'] = "$#{self.math.strip}$"
        img['class'] = 'maruku-png'
        img
      end

      def to_html_inline_math
        mathml = get_setting(:html_math_output_mathml) && render_mathml(:inline, self.math)
        if mathml
          mathml.add_class('maruku-mathml')
          return mathml.to_html
        end

        png = get_setting(:html_math_output_png) && render_png(:inline, self.math)

        HTMLElement.new 'span', 'class' => 'maruku-inline' do
          # TODO: It seems weird that we output an empty span if there's no PNG
          if png
            adjust_png(png, true)
          end
        end
      end

      def to_html_equation
        mathml = get_setting(:html_math_output_mathml) && render_mathml(:equation, self.math)
        png    = get_setting(:html_math_output_png)    && render_png(:equation, self.math)

        div = xelem('div')
        div['class'] = 'maruku-equation'
        if mathml
          if self.label  # then numerate
            span = xelem('span')
            span['class'] = 'maruku-eq-number'
            span << xtext("(#{self.num})")
            div << span
            div['id'] = "eq:#{self.label}"
          end
          mathml.add_class('maruku-mathml')
          div << mathml.to_html
        end

        if png
          img = adjust_png(png, false)
          div << img
          if self.label  # then numerate
            span = xelem('span')
            span['class'] = 'maruku-eq-number'
            span << xtext("(#{self.num})")
            div << span
            div['id'] = "eq:#{self.label}"
          end
        end

        div
      end

      def to_html_eqref
        unless eq = self.doc.eqid2eq[self.eqid]
          maruku_error "Cannot find equation #{self.eqid.inspect}"
          return xtext("(eq:#{self.eqid})")
        end

        a = xelem('a')
        a['class'] = 'maruku-eqref'
        a['href'] = "#eq:#{self.eqid}"
        a << xtext("(#{eq.num})")
        a
      end

      def to_html_divref
        unless hash = self.doc.refid2ref.values.find {|h| h.has_key?(self.refid)}
          maruku_error "Cannot find div #{self.refid.inspect}"
          return xtext("\\ref{#{self.refid}}")
        end
        ref= hash[self.refid]

        a = xelem('a')
        a['class'] = 'maruku-ref'
        a['href'] = "#" + self.refid
        a << xtext(ref.num.to_s)
        a
      end

      def to_html_citation
        span = xelem('span')
        span['class'] = 'maruku-citation'
        span << xtext('[')
        self.cites.each do |c|
          if c =~ /(\w+):(\d\d\d\d\w{2,3})/ # INSPIRE
            a = xelem('a')
            a << xtext(c)
            a['href'] = "http://inspirehep.net/search?p=#{$1}%3A#{$2}"
            span << a << xtext(',')
          elsif c =~ /MR(\d+)/ # MathReviews
            a = xelem('a')
            a << xtext(c)
            a['href'] = "http://www.ams.org/mathscinet-getitem?mr=#{$1}"
            span << a << xtext(',')
          else
            span << xtext(c + ',')
          end
        end
        span.children.last.chop! unless span.children.last == '['
        span << xtext(']')
        span
      end

    end
  end
end
