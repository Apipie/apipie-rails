module Api
  module V2
    class EmptyMiddleController < V2::BaseController
      # This is an empty controller, used to test cases where controllers
      # may inherit from a middle controller that does not define a resource_description,
      # but the middle controller's parent does.

      def inconsequential_method
        # This method is here to ensure that the controller is not empty.
        # It triggers method_added, which is used to add the resource description.
      end
    end
  end
end
