module Api
  module V2
    class BaseController < Api::BaseController
      resource_description do
        version '2.0'
        app_info 'Version 2.0 description'
        api_base_url '/api/v2'
      end
    end
  end
end
