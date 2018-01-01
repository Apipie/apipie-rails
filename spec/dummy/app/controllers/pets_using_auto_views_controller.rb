#
# demonstration of how the 'describe_own_properties' method can be used
# to integrate Apipie response descriptions with view generation packages
# such as, for example, Grape::Entity
#

# Consider a hypothetical SelfDocumentingView class (a stand-in for Grape::Entity
# for demonstrational purposes). This is an abstract class, supporting the implementation
# of actual views as subclasses of SelfDocumentingView.
#
# A user of SelfDocumentingView would implement a subclass for each desired view.  Each such
# view definition would include, for each field that should be returned in the JSON response,
# an instance method called v_<name>__<type>.
#
# SelfDocumentingView would then scan the subclass for such fields and:
# 1. Given an id:  fetch the matching model and generated a view from it using the field definitions
# 2. Describe the structure of such views to Apipie using self.describe_own_properties
#
# (see the controller implementation below for how such a class might be used)

class SelfDocumentingView
  # self.describe_own_properties (a class method) generates the meta-data
  # (i.e., the type description) for the subclass.
  def self.describe_own_properties
    (self.instance_methods - self.class.instance_methods).map{|m|
      if matchdata = /^v_(\w+)__(\w+)$/.match(m)
        Apipie::prop(matchdata[1], matchdata[2])
      end
    }.compact
  end

  # to_json (an instance method) generates the actual view
  def to_json
    { note: "in an actual implementation of SelfDocumentingView, this method
             would call each v_<name>__<type> method and include its output
             in the response as a (<name>: <value>) pair"
    }
  end

  def initialize(id)
    load_from_model(id)
  end

  def load_from_model(id)
    # in a real implementation of SelfDocumentingView, this
    # method would load the fields to be displayed from the model
    # instance identified by 'id'
  end
end


#
# ViewOfPet extends SelfDocumentingView to include specific fields
#
class ViewOfPet < SelfDocumentingView
  attr_accessor :v_pet_name__string
  attr_accessor :v_animal_type__string
  attr_accessor :v_age__number
end


class PetsUsingAutoViewsController < ApplicationController
  #-----------------------------------------------------------
  # Method returning an array of AutomatedViewOfPet (where
  # AutomatedViewOfPet is an auto-generated self-describing class)
  # -----------------------------------------------------------
  api :GET, "/pet_described_using_automated_view/:id", "Get the measurements of a single pet"
  param :id, String
  returns ViewOfPet, :desc => "like Pet, but different"
  def pet_described_using_automated_view
    render :plain => ViewOfPet.new(params.id).to_json
  end
end
