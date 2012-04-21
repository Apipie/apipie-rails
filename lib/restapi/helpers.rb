module Restapi
  module Helpers
    def markup_to_html(text)
      Restapi.configuration.markup.to_html(text.strip_heredoc)
    end

    def full_url(path)
      unless @prefix
        @prefix = ""
        if rails_prefix = ENV["RAILS_RELATIVE_URL_ROOT"]
          @prefix << rails_prefix
        end
        @prefix << Restapi.configuration.doc_base_url
      end
      path = path.sub(/^\//,"")
      "#{@prefix}/#{path}"
    end
  end
end
