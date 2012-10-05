unless RestClient.const_defined? :OAUTH_EXTENSION
  RestClient::OAUTH_EXTENSION = lambda do |request, args|
    if args[:oauth]
      uri             = URI.parse args[:url]
      default_options = { :site               => "#{uri.scheme}://#{uri.host}:#{uri.port.to_s}",
                          :request_token_path => "",
                          :authorize_path     => "",
                          :access_token_path  => "" }
      options         = default_options.merge args[:oauth][:options] || { }
      consumer        = OAuth::Consumer.new(args[:oauth][:consumer_key], args[:oauth][:consumer_secret], options)

      consumer.sign!(request)
    end
  end
end

unless RestClient.before_execution_procs.include? RestClient::OAUTH_EXTENSION
  RestClient.add_before_execution_proc &RestClient::OAUTH_EXTENSION
end
