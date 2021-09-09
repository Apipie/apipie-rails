class PetsOneOfController < ApplicationController
  resource_description do
    description 'A controller to test discriminated unions with the OneOfValidator'
    short 'Pets'
    path '/pets'

    param :common_param, Integer, desc: 'A param that can optionally be passed to all Pet methods', required: false

    returns code: 404 do
      property :error_message, String, 'description of the error'
    end
  end

  def_param_group :pet_common do
    param :name, String, desc: 'Name of pet'
    param :age, Integer, desc: 'Age of pet in years'
    param :numeric_attributes, Hash, of: Integer
  end

  def_param_group :dog do
    param :animal_type, ['dog'], desc: 'Type of pet'
    param_group :pet_common, PetsOneOfController
    param :bark_volume, :decimal, desc: "The average volume of the dog's bark in decibels"
    param :tag_id, :one_of do
      param nil, Integer
      param nil, String
    end
  end

  def_param_group :cat do
    param :animal_type, ['cat'], desc: 'Type of pet'
    param_group :pet_common, PetsOneOfController
    param :meow_frequency, :decimal, desc: "The fundamental frequency of the cat's meow in hertz"
    param :meow_types, Hash, of: :one_of do
      param :meow_description, Hash do
        param :volume, :decimal
        param :tone, :decimal
        param :timbre, String
      end
    end
  end

  def_param_group :pet do
    param :data, :one_of, discriminator_property: :animal_type do
      param :dog, Hash, discriminator: 'dog' do
        param_group :dog, PetsOneOfController
      end
      param :cat, Hash, discriminator: 'cat' do
        param_group :cat, PetsOneOfController
      end
    end
  end

  def_param_group :index_pets_response do
    param :data, Array, of: :one_of, discriminator_property: :animal_type do
      param :dog, Hash, discriminator: 'dog' do
        param_group :dog, PetsOneOfController
      end
      param :cat, Hash, discriminator: 'cat' do
        param_group :cat, PetsOneOfController
      end
    end
  end

  def_param_group :show_pet_response do
    param_group :pet, PetsOneOfController
  end
  
  def_param_group :create_pet_request do
    param_group :pet, PetsOneOfController
  end

  def_param_group :created_by_day_response do
    # Defining a nested array type with one_of
    param :data, Array, of: :one_of do
      param :point, Array, of: Hash do
        property :date, String
        property :count, Integer
      end
    end
  end

  api :GET, '/pets', 'Retrieve all pets'
  returns :index_pets_response
  def index
    render plain: "OK #{params.inspect}"
  end

  api :GET, '/pets/:id', 'Retrieve a pet by ID'
  returns :show_pet_response
  def show
    render plain: "OK #{params.inspect}"
  end

  api :POST, '/pets', 'Create a new pet'
  param_group :create_pet_request
  returns :show_pet_response
  def create
    render plain: "OK #{params.inspect}"
  end

  api :GET, '/pets/created_by_day', 'Create a new pet'
  returns :created_by_day_response
  def created_by_day
    render plain: "OK #{params.inspect}"
  end
end

