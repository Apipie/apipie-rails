module Apipie

  module Markup

    class RDoc

      def initialize
        require 'rdoc'
        require 'rdoc/markup/to_html'
        if Gem::Version.new(::RDoc::VERSION) < Gem::Version.new('4.0.0')
          @rdoc ||= ::RDoc::Markup::ToHtml.new()
        else
          @rdoc ||= ::RDoc::Markup::ToHtml.new(::RDoc::Options.new)
        end
      end

      def to_html(text)
        @rdoc.convert(text)
      end

    end

    class Markdown

      def initialize
        require 'redcarpet'
      end

      def to_html(text)
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, no_intra_emphasis: true)
        markdown.render(text)
      end

    end

    class Textile

      def initialize
        require 'RedCloth'
      end

      def to_html(text)
        RedCloth.new(text).to_html
      end

    end

  end
end
