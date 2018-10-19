#
# The TagsController defined here provides an example of a
# tags call without a resource description.
#

class TaggedDogsController < ActionController::Base
  #-----------------------------------------------------------
  # simple 'returns' example: a method that returns a cat record
  #-----------------------------------------------------------
  api :GET, "/pets/:id/as_properties", "Get a dog record"
  tags(%w[Dogs Wolves])
  def show_as_properties
    render :plain => "showing pet properties"
  end
end