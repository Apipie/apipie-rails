module Api
  module V1
    class BaseController < Api::BaseController
      resource_description do
        api_version '1.0'
        app_info 'Version 1.0 description'
        api_base_url '/api/v1'
      end

      def_param_group :pagination do
        param :page, Integer, 'The page of the resource.'
        param :items_per_page, Integer, 'The number of items per page.'
      end

      def_param_group :identifier do
        param :identifier, Integer, 'The identifier of the resource.'
      end
    end
  end
end
