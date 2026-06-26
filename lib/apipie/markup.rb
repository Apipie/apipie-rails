module Apipie

  module Markup

    class RDoc

      def initialize
        require 'rdoc'
        require 'rdoc/markup/to_html'
      end

      def to_html(text)
        rdoc.convert(text)
      end

      private

      def rdoc
        rdoc_version = Gem::Version.new(::RDoc::VERSION)
        if rdoc_version >= Gem::Version.new('4.0.0') && rdoc_version < Gem::Version.new('8.0.0')
          ::RDoc::Markup::ToHtml.new(::RDoc::Options.new)
        else
          ::RDoc::Markup::ToHtml.new()
        end
      end
    end

    class Markdown

      def initialize
        require 'maruku'
      end

      def to_html(text)
        Maruku.new(text).to_html
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
