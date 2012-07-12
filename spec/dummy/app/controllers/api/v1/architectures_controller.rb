module Api
  module V1
    class ArchitecturesController < V1::BaseController
      resource_description { name 'Architectures' }
      api :GET, "/architectures/", "List all architectures."
      def index
      end

      api :GET, "/architectures/:id/", "Show an architecture."
      def show
      end

      api :POST, "/architectures/", "Create an architecture."
      param :architecture, Hash, :required => true do
        param :name, String, :required => true
      end
      def create
      end

      api :PUT, "/architectures/:id/", "Update an architecture."
      param :architecture, Hash, :required => true do
        param :name, String
      end
      def update
      end

      api :DELETE, "/architecturess/:id/", "Delete an architecture."
      def destroy
      end
    end
  end
end
