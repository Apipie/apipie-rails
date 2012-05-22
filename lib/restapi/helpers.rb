module Restapi
  module Helpers
    def markup_to_html(text)
      Restapi.configuration.markup.to_html(text.strip_heredoc)
    end

    attr_accessor :url_prefix

    def full_url(path)
      unless @url_prefix
        @url_prefix = ""
        if rails_prefix = ENV["RAILS_RELATIVE_URL_ROOT"]
          @url_prefix << rails_prefix
        end
        @url_prefix << Restapi.configuration.doc_base_url
      end
      path = path.sub(/^\//,"")
      ret = "#{@url_prefix}/#{path}"
      ret.insert(0,"/") unless ret =~ /\A[.\/]/
      ret.sub!(/\/*\Z/,"")
      ret
    end
  end
end
