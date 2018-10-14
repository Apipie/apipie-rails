#
# The TagsController defined here provides an example of a resource_description
# defining a set of tags for the contained methods to include.
#

class TaggedCatsController < ApplicationController
  resource_description do
    description 'A controller to test "returns"'
    short 'Pets'
    path '/pets'

    tags(%w[Dogs Pets])
  end

  #-----------------------------------------------------------
  # simple 'returns' example: a method that returns a pet record
  #-----------------------------------------------------------
  api :GET, "/pets/:id/as_properties", "Get a pet record"
  tags(%w[Animals])
  def show_as_properties
    render :plain => "showing pet properties"
  end
end
