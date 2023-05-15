module Api
  module V2
    module Sub
      class FootgunsController < V2::EmptyMiddleController
        resource_description do
          short 'Footguns are bad'
        end

        api :GET, '/footguns/', 'List all footguns.'
        def index; end

        api :GET, '/footguns/:id/', 'Show a footgun.'
        def show; end

        api :POST, '/footguns/', 'Create a footgun.'
        def create; end

        api :PUT, '/footguns/:id/', 'Update a footgun.'
        param :footgun, Hash, :required => true do
          param :name, String
        end
        def update; end

        api! 'Delete a footgun.'
        api_version '2.0' # forces removal of the method description
        def destroy; end
      end
    end
  end
end
