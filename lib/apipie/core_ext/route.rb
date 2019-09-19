module Apipie
  module BaseUrlExtension
    attr_accessor :base_url
  end
end

class ActionDispatch::Journey::Route
  include Apipie::BaseUrlExtension
end
