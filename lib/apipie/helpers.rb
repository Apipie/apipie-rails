module Apipie
  module Helpers
    def markup_to_html(text)
      return "" if text.nil?
      if Apipie.configuration.markup.respond_to? :to_html
        Apipie.configuration.markup.to_html(text.strip_heredoc)
      else
        text.strip_heredoc
      end
    end

    attr_accessor :url_prefix

    def request_script_name
      Thread.current[:apipie_req_script_name] || ""
    end

    def request_script_name=(script_name)
      Thread.current[:apipie_req_script_name] = script_name
    end

    def full_url(path)
      unless @url_prefix
        @url_prefix = ""
        @url_prefix << request_script_name
        @url_prefix << Apipie.configuration.doc_base_url
      end
      path = path.sub(/^\//,"")
      ret = "#{@url_prefix}/#{path}"
      ret.insert(0,"/") unless ret =~ /\A[.\/]/
      ret.sub!(/\/*\Z/,"")
      ret
    end

    def include_javascripts
      %w[ bundled/jquery-1.7.2.js
          bundled/bootstrap-collapse.js
          bundled/prettify.js
          apipie.js ].map do |file|
        "<script type='text/javascript' src='#{Apipie.full_url("javascripts/#{file}")}'></script>"
      end.join("\n").html_safe
    end

    def include_stylesheets
      %w[ bundled/bootstrap.min.css
          bundled/prettify.css
          bundled/bootstrap-responsive.min.css ].map do |file|
        "<link type='text/css' rel='stylesheet' href='#{Apipie.full_url("stylesheets/#{file}")}'/>"
      end.join("\n").html_safe
    end
  end
end
