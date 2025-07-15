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
        if Gem::Version.new(::RDoc::VERSION) < Gem::Version.new('4.0.0')
          ::RDoc::Markup::ToHtml.new()
        else
          ::RDoc::Markup::ToHtml.new(::RDoc::Options.new)
        end
      end
    end

    class Markdown

      def initialize
        require 'commonmarker'
      end

      def to_html(text)
        Commonmarker.to_html(text, options: {
          parse: { smart: true },
          render: {
            hardbreaks: false,
            unsafe: false,
            escape: true
          },
          extension: {
            strikethrough: true,
            tagfilter: true,
            table: true,
            autolink: true,
            tasklist: true
          }
        })
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
