module Api
  module V2
    class BaseController < Api::BaseController
      resource_description do
        api_version '2.0'
        app_info 'Version 2.0 description'
        api_base_url '/api/v2'

        name :reversed_name
      end

      def self.reversed_name
        controller_name.capitalize.reverse
      end
    end
  end
end
