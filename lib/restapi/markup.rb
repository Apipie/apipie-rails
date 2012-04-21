module Restapi
  
  module Markup
    
    class RDoc
      
      def initialize
        require 'rdoc'
        require 'rdoc/markup/to_html'
        @rdoc ||= ::RDoc::Markup::ToHtml.new
      end
      
      def to_html(text)
        @rdoc.convert(text)
      end
      
    end
    
    class Markdown
      
      def initialize
        require 'redcarpet'
        @redcarpet ||= ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML.new)
      end
      
      def to_html(text)
        @redcarpet.render(text)
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