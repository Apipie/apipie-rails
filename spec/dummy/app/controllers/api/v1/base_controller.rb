module Api
  module V1
    class BaseController < Api::BaseController
      resource_description { version '1.0' }
    end
  end
end
