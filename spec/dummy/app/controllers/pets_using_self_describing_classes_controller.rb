#----------------------------------------------------------------------------------------------------
# A "self-describing class" is a class that respond_to? :describe_own_properties
# and returns an array of Property Descriptions.
# (The simple way to create Property Description objects is using the Apipie::prop helper function,
# which is a factory for Apipie::ResponseDescriptionAdapter::PropDesc instances)
#
#----------------------------------------------------------------------------------------------------


# in this example, Pet is a self-describing class with only two properties.
# In a real implementation, the Pet class would actually do something with these properties.
# Here, the class is defined to only include the describe_own_properties method.
class Pet
  def self.describe_own_properties
    [
      Apipie::prop(:pet_name, 'string', {:description => 'Name of pet', :required => false}),
      Apipie::prop(:animal_type, 'string', {:description => 'Type of pet', :values => %w[dog cat iguana kangaroo]}),
      Apipie::additional_properties(false)
    ]
  end
end

#
# PetWithMeasurements is a self-describing class with an embedded object
#
class PetWithMeasurements
  def self.describe_own_properties
    [
      Apipie::prop(:pet_name, 'string', {:description => 'Name of pet', :required => false}),
      Apipie::prop('animal_type', 'string', {:description => 'Type of pet', :values => %w[dog cat iguana kangaroo]}),
      Apipie::prop(:pet_measurements, 'object', {}, [
                     Apipie::prop(:weight, 'number', {:description => "Weight in pounds" }),
                     Apipie::prop(:height, 'number', {:description => "Height in inches" }),
                     Apipie::prop(:num_legs, 'number', {:description => "Number of legs", :required => false }),
                     Apipie::additional_properties(false)
                   ])
    ]
  end
end

#
# PetWithManyMeasurements is a self-describing class with an embedded object
#
class PetWithManyMeasurements
  def self.describe_own_properties
    [
      Apipie::prop(:pet_name, 'string', {:description => 'Name of pet', :required => false}),
      Apipie::prop(:many_pet_measurements, 'object', {is_array: true}, [
                     Apipie::prop(:weight, 'number', {:description => "Weight in pounds" }),
                     Apipie::prop(:height, 'number', {:description => "Height in inches" }),
                   ])
    ]
  end
end



class PetsUsingSelfDescribingClassesController < ApplicationController
  resource_description do
    description 'A controller to test "returns" using self-describing classes'
    short 'Pets'
    path '/pets2'
  end

  #-----------------------------------------------------------
  # Method returning an array of Pet (a self-describing class)
  # -----------------------------------------------------------
  api :GET, "/pets_described_as_class", "Get all pets"
  returns :array_of => Pet, :desc => "list of pets"
  def pets_described_as_class
    render :plain => "all pets"
  end

  #-----------------------------------------------------------
  # Method returning an array of PetWithMeasurements (a self-describing class)
  # -----------------------------------------------------------
  api :GET, "/pets_with_measurements_described_as_class/:id", "Get the measurements of a single pet"
  param :id, String
  returns PetWithMeasurements, :desc => "measurements of the pet"
  def pets_with_measurements_described_as_class
    render :plain => "all pets"
  end

  #-----------------------------------------------------------
  # Method returning an array of PetWithManyMeasurements (a self-describing class with array field)
  # -----------------------------------------------------------
  api :GET, "/pets_with_many_measurements_as_class/:id", "Get the measurements of a single pet"
  param :id, String
  returns PetWithManyMeasurements, :desc => "measurements of the pet"
  def pets_with_many_measurements_as_class
    render :plain => "all pets"
  end

end

