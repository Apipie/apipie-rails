module Api
  module V2
    class EmptyMiddleController < V2::BaseController
      # This is an empty controller, used to test cases where controllers
      # may inherit from a middle controler that does not define a resource_description,
      # but the middle controller's parent does.
    end
  end
end
