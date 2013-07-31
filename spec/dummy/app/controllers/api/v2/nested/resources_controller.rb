module Api
  module V2
    class Nested::ResourcesController < V2::BaseController
      resource_description do 
        name 'Resources'
        resource_id "resource"
      end
      api :GET, "/nested/resources/", "List all nested resources."
      def index
      end

      api :GET, "/nested/resources/:id/", "Show a nested resource."
      def show
      end

      api :POST, "/nested/resources/", "Create a nested resource."
      param_group :arch, Api::V1::ArchitecturesController
      def create
      end

      api :PUT, "/nested/resources/:id/", "Update a nested resource."
      param :architecture, Hash, :required => true do
        param :name, String
      end
      def update
      end

      api :DELETE, "/resources/:id/", "Delete a nested resource."
      def destroy
      end
    end
  end
end
