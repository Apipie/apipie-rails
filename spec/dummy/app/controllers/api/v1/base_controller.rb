module Api
  module V1
    class BaseController < Api::BaseController
      resource_description do
        version '1.0'
        app_info 'Version 1.0 description'
        api_base_url '/api/v1'
      end
    end
  end
end
