module Api
  module V2
    module Nested
      class ArchitecturesController < V2::BaseController
        resource_description { name 'Architectures' }
        api :GET, "/nested/architectures/", "List all nested architectures."
        def index
        end

        api :GET, "/nested/architectures/:id/", "Show a nested architecture."
        def show
        end

        api :POST, "/nested/architectures/", "Create a nested architecture."
        param_group :arch, Api::V1::ArchitecturesController
        def create
        end

        api :PUT, "/nested/architectures/:id/", "Update a nested architecture."
        param :architecture, Hash, :required => true do
          param :name, String
        end
        def update
        end

        api :DELETE, "/architecturess/:id/", "Delete a nested architecture."
        def destroy
        end
      end
    end
  end
end
