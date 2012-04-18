module Restapi
  module Helpers
    def rdoc
      @rdoc ||= RDoc::Markup::ToHtml.new
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
