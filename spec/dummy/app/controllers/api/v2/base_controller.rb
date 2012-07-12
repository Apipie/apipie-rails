module Api
  module V2
    class BaseController < Api::BaseController
      resource_description { version '2.0' }
    end
  end
end
