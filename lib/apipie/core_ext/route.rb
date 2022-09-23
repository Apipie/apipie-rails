module Apipie
  module BaseUrlExtension
    attr_accessor :base_url
  end
end

module ActionDispatch
  module Journey
    class Route
      include Apipie::BaseUrlExtension
    end
  end
end
