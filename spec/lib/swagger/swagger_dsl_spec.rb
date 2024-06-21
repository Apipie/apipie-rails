require 'spec_helper'
require 'rack/utils'
require 'rspec/expectations'

describe "Swagger Responses" do
  let(:desc) { Apipie.get_resource_description(controller_class, Apipie.configuration.default_version) }

  let(:swagger) do
    Apipie.configuration.generator.swagger.suppress_warnings = true
    Apipie.to_swagger_json(Apipie.configuration.default_version, controller_class.to_s.underscore.sub("_controller", ""))
  end

  let(:controller_class ) { described_class }

  def get_ref(ref)
    name = ref.split('#/definitions/')[1].to_sym
    swagger[:definitions][name]
  end

  def resolve_refs(schema)
    if schema['$ref']
      return get_ref(schema['$ref'])
    end
    schema
  end

  def swagger_response_for(path, code = 200, method = 'get')
    response = swagger[:paths][path][method][:responses][code]
    response[:schema] = resolve_refs(response[:schema])
    response
  end

  def swagger_params_for(path, method = 'get')
    swagger[:paths][path][method][:parameters]
  end

  def swagger_param_by_name(param_name, path, method = 'get')
    params = swagger_params_for(path, method)
    matching = params.select{|p| p[:name] == param_name }
    raise "multiple params named [#{param_name}] in swagger definition for [#{method} #{path}]" if matching.length > 1

    nil if matching.length == 0

    matching[0]
  end




  #
  # Matcher to validate the hierarchy of fields described in an internal 'returns' object (without checking their type)
  #
  # For example, code such as:
  #           returns_obj = Apipie.get_resource_description(...)._methods.returns.detect{|e| e.code=200})
  #           expect(returns_obj).to match_param_structure([:pet_name, :animal_type, :pet_measurements => [:weight, :height]])
  #
  # will verify that the payload structure described for the response of return code 200 is:
  #           {
  #             "pet_name": <any>,
  #             "animal_type": <any>,
  #             "pet_measurements": {
  #                 "weight": <any>,
  #                 "height": <any>
  #             }
  #           }
  #
  #
  RSpec::Matchers.define :match_field_structure do |expected|
    @last_message = nil

    match do |actual|
      deep_match?(actual, expected)
    end

    def deep_match?(actual, expected, breadcrumb = [])
      pending_params = actual.params_ordered.dup
      expected.each do |expected_param|
        expected_param_name = expected_param.is_a?(Hash) ? expected_param.keys.first : expected_param
        actual_param = pending_params.find { |param| param.name.to_s == expected_param_name.to_s }
        unless actual_param
          @fail_message = "Couldn't find #{expected_param_name.inspect} among #{pending_params.map(&:name)} in #{breadcrumb.join('.')}"
          return false
        else
          pending_params.delete_if { |p| p.object_id ==  actual_param.object_id }
        end

        return false unless fields_match?(actual_param, expected_param_name, breadcrumb)
        if expected_param.is_a? Hash
          return false unless deep_match?(actual_param.validator, expected_param.values[0], breadcrumb + [expected_param.keys.first])
        end
      end

      unless pending_params.empty?
        @fail_message = "Unexpected properties #{pending_params.map(&:name)} in #{breadcrumb.join('.')}"
        return false
      end
      true
    end

    def fields_match?(param, expected_name, breadcrumb)
      return false unless have_field?(param, expected_name, breadcrumb)
      @fail_message = "expected #{(breadcrumb + [param.name]).join('.')} to eq #{(breadcrumb + [expected_name]).join('.')}"
      param.name.to_s == expected_name.to_s
    end

    def have_field?(field, expected_name, breadcrumb)
      @fail_message = "expected property #{(breadcrumb+[expected_name]).join('.')}"
      !field.nil?
    end

    failure_message do |actual|
      @fail_message
    end
  end


  describe PetsController do


    describe "PetsController#index" do
      subject do
        desc._methods[:index]
      end

      it "returns code 200 with array of entries of the format {'pet_name', 'animal_type'}" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(true)

        expect(returns_obj).to match_field_structure([:pet_name, :animal_type])
      end

      it 'has the response described in the swagger' do
        response = swagger_response_for('/pets')
        expect(response[:description]).to eq("list of pets")

        schema = response[:schema]
        expect(schema[:type]).to eq("array")

        a_schema = resolve_refs(schema[:items])
        expect(a_schema).to have_field(:pet_name, 'string', {:description => 'Name of pet', :required => false})
        expect(a_schema).to have_field(:animal_type, 'string', {:description => 'Type of pet', :enum => %w[dog cat iguana kangaroo]})
      end


      it "returns code 401 with a String description field" do
        returns_obj = subject.returns.detect{|e| e.code == 404 }

        expect(returns_obj.code).to eq(404)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:error_message])
      end


      it "returns code 401 with a :reason field (defined in the superclass)" do
        returns_obj = subject.returns.detect{|e| e.code == 401 }

        expect(returns_obj.code).to eq(401)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:reason])
      end

      it 'has the 404 response described in the swagger' do
        response = swagger_response_for('/pets', 404)
        expect(response[:description]).to eq("Not Found")

        schema = response[:schema]
        expect(schema[:type]).to eq("object")

        expect(schema).to have_field(:error_message, 'string', {:description => 'description of the error', :required => true})
      end

    end

    describe "PetsController#show_plain_response_with_tags" do
      subject do
        desc._methods[:show_plain_response_with_tags]
      end

      it "returns tags with 'Dogs', 'Cats', and 'LivingBeings'" do
        returns_obj = subject.tag_list
        puts returns_obj.inspect

        expect(returns_obj.tags).to eq(%w[Dogs Cats LivingBeings])
      end
    end

    describe "PetsController#show_as_properties" do
      subject do
        desc._methods[:show_as_properties]
      end

      it "returns code 200 with 'pet_name' and 'animal_type'" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name, :animal_type])
      end

      it 'has the response described in the swagger' do
        response = swagger_response_for('/pets/{id}/as_properties')
        expect(response[:description]).to eq("OK")

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:description => 'Name of pet', :required => false})
        expect(schema).to have_field(:animal_type, 'string', {:description => 'Type of pet', :enum => %w[dog cat iguana kangaroo]})
      end

      it 'has the 404 response description overridden' do
        returns_obj = subject.returns.detect{|e| e.code == 404 }

        # puts returns_obj.to_json
        expect(returns_obj.code).to eq(404)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:another_error_message])
      end
    end

    describe "PetsController#show_as_param_group_of_properties" do
      subject do
        desc._methods[:show_as_param_group_of_properties]
      end

      it "returns code 200 with 'pet_name' and 'animal_type'" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name, :animal_type])
        expect(returns_obj.params_ordered[0].is_required?).to be_falsey
        expect(returns_obj.params_ordered[1].is_required?).to be_truthy
      end

      it 'has the response described in the swagger' do
        response = swagger_response_for('/pets/{id}/as_param_group_of_properties')
        expect(response[:description]).to eq("The pet")

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:description => 'Name of pet', :required => false})
        expect(schema).to have_field(:animal_type, 'string', {:description => 'Type of pet', :enum => %w[dog cat iguana kangaroo]})
      end
    end

    describe "PetsController#show_pet_by_id" do
      subject do
        desc._methods[:show_pet_by_id]
      end

      it "has only oauth (from ApplicationController), common_param (from resource) and pet_id as an input parameters" do
        params_obj = subject.params_ordered

        expect(params_obj[0].name).to eq(:oauth)
        expect(params_obj[1].name).to eq(:common_param)
        expect(params_obj[2].name).to eq(:pet_id)
      end

      it "returns code 200 with 'pet_id', pet_name' and 'animal_type'" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(false)

        # note that the response is expected NOT to return the parameters marked ':only_in => :request'
        expect(returns_obj).to match_field_structure([:pet_id, :pet_name, :animal_type])
      end

      it 'has the response described in the swagger' do
        response = swagger_response_for('/pets/pet_by_id')
        expect(response[:description]).to eq("OK")

        schema = response[:schema]
        expect(schema).to have_field(:pet_id, 'number', {:description => 'id of pet'})
        expect(schema).to have_field(:pet_name, 'string', {:description => 'Name of pet', :required => false})
        expect(schema).to have_field(:animal_type, 'string', {:description => 'Type of pet', :enum => %w[dog cat iguana kangaroo]})
        expect(schema).not_to have_field(:partial_match_allowed, 'boolean', {:required => false})
      end

      it "creates a swagger definition with all input parameters" do
        # a parameter defined for this method
        expect(swagger_param_by_name(:pet_id, '/pets/pet_by_id')[:type]).to eq('number')

        # a parameter defined for the resource
        expect(swagger_param_by_name(:common_param, '/pets/pet_by_id')[:type]).to eq('number')

        # a parameter defined in the controller's superclass
        expect(swagger_param_by_name(:oauth, '/pets/pet_by_id')[:type]).to eq('string')
      end

    end

    describe "PetsController#get_vote_by_owner_name" do
      subject do
        desc._methods[:get_vote_by_owner_name]
      end

      it "returns code 200 with 'owner_name' and 'vote'" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:owner_name, :vote])
      end

      it 'has the response described in the swagger' do
        response = swagger_response_for('/pets/by_owner_name/did_vote')
        expect(response[:description]).to eq("OK")

        schema = response[:schema]
        expect(schema).to have_field(:owner_name, 'string', {:required => false}) # optional because defined using 'param', not 'property'
        expect(schema).to have_field(:vote, 'boolean')
      end
    end

    describe "PetsController#show_extra_info" do
      subject do
        desc._methods[:show_extra_info]
      end

      it "returns code 201 with 'pet_name' and 'animal_type'" do
        returns_obj = subject.returns.detect{|e| e.code == 201 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(201)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name, :animal_type])
      end

      it 'has the 201 response described in the swagger' do
        response = swagger_response_for('/pets/{id}/extra_info', 201)
        expect(response[:description]).to eq("Found a pet")

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:required => false})
        expect(schema).to have_field(:animal_type, 'string')
      end

      it "returns code 202 with spread out 'pet' and encapsulated 'pet_measurements'" do
        returns_obj = subject.returns.detect{|e| e.code == 202 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(202)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name,
                                                      :animal_type,
                                                      {:pet_measurements => [:weight, :height, :num_legs]}
                                                     ])
      end

      it 'has the 202 response described in the swagger' do
        response = swagger_response_for('/pets/{id}/extra_info', 202)
        expect(response[:description]).to eq('Accepted')

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:required => false})
        expect(schema).to have_field(:animal_type, 'string')
        expect(schema).to have_field(:pet_measurements, 'object')

        pm_schema = schema[:properties][:pet_measurements]
        expect(pm_schema).to have_field(:weight, 'number', {:description => "Weight in pounds"})
        expect(pm_schema).to have_field(:height, 'number', {:description => "Height in inches"})
        expect(pm_schema).to have_field(:num_legs, 'number', {:description => "Number of legs", :required => false})
      end

      it "returns code 203 with spread out 'pet', encapsulated 'pet_measurements' and encapsulated 'pet_history'" do
        returns_obj = subject.returns.detect{|e| e.code == 203 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(203)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name,
                                                      :animal_type,
                                                      {:pet_measurements => [:weight, :height,:num_legs]},
                                                      {:pet_history => [:did_visit_vet, :avg_meals_per_day]},
                                                      {:additional_histories => [:did_visit_vet, :avg_meals_per_day]}
                                                     ])
      end

      it 'has the 203 response described in the swagger' do
        response = swagger_response_for('/pets/{id}/extra_info', 203)
        expect(response[:description]).to eq('Non-Authoritative Information')

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:required => false})
        expect(schema).to have_field(:animal_type, 'string')
        expect(schema).to have_field(:pet_measurements, 'object')
        expect(schema).to have_field(:pet_history, 'object')
        expect(schema).to have_field(:additional_histories, 'array')

        pm_schema = schema[:properties][:pet_measurements]
        expect(pm_schema).to have_field(:weight, 'number', {:description => "Weight in pounds"})
        expect(pm_schema).to have_field(:height, 'number', {:description => "Height in inches"})
        expect(pm_schema).to have_field(:num_legs, 'number', {:description => "Number of legs", :required => false})

        ph_schema = schema[:properties][:pet_history]
        expect(ph_schema).to have_field(:did_visit_vet, 'boolean')
        expect(ph_schema).to have_field(:avg_meals_per_day, 'number')

        pa_schema = schema[:properties][:additional_histories]
        expect(pa_schema[:type]).to eq('array')
        pai_schema = schema[:properties][:additional_histories][:items]
        expect(pai_schema).to have_field(:did_visit_vet, 'boolean')
        expect(pai_schema).to have_field(:avg_meals_per_day, 'number')
      end

      it "returns code 204 with array of integer" do
        returns_obj = subject.returns.detect{|e| e.code == 204 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(204)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:int_array, :enum_array])
      end

      it 'has the 204 response described in the swagger' do
        response = swagger_response_for('/pets/{id}/extra_info', 204)

        schema = response[:schema]
        expect(schema).to have_field(:int_array, 'array', {items: {type: 'number'}})
        expect(schema).to have_field(:enum_array, 'array', {items: {type: 'string', enum: %w[v1 v2 v3]}})
      end


      it "returns code matching :unprocessable_entity (422) with spread out 'pet' and 'num_fleas'" do
        returns_obj = subject.returns.detect{|e| e.code == 422 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(422)

        expect(returns_obj).to match_field_structure([:pet_name,
                                                      :animal_type,
                                                      :num_fleas
                                                     ])
      end

      it 'has the 422 response described in the swagger' do
        response = swagger_response_for('/pets/{id}/extra_info', 422)
        expect(response[:description]).to eq('Fleas were discovered on the pet')

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:required => false})
        expect(schema).to have_field(:animal_type, 'string')
        expect(schema).to have_field(:num_fleas, 'number')
      end

    end

  end

  #==============================================================================
  # TaggedDogsController is a demonstration of how tags may be defined in a simple
  # controller class without defining either the controller resource-description
  # block or the controller's superclass's resource-description block.
  #==============================================================================

  describe TaggedDogsController do
    describe "TaggedDogsController#show_as_properties" do
      subject do
        desc._methods[:show_as_properties]
      end

      it "returns tags with 'Dogs', and 'Wolves'" do
        returns_obj = subject.tag_list
        puts returns_obj.inspect

        expect(returns_obj.tags).to eq(%w[Dogs Wolves])
      end
    end
  end

  #==============================================================================
  # TaggedCatsController is a demonstration of how tags may be defined in the
  # controller's resource description so that they may be automatically prefixed
  # to a particular operation's tags.
  #==============================================================================

  describe TaggedCatsController do
    describe "TaggedCatsController#show_as_properties" do
      subject do
        desc._methods[:show_as_properties]
      end

      it "returns tags with 'Dogs', 'Pets', and 'Animals'" do
        returns_obj = subject.tag_list
        puts returns_obj.inspect

        expect(returns_obj.tags).to eq(%w[Dogs Pets Animals])
      end
    end

    describe "TaggedCatsController#show_as_same_properties" do
      subject do
        desc._methods[:show_as_same_properties]
      end

      it "returns tags with 'Dogs', 'Pets', 'Puma', and 'Animals'" do
        returns_obj = subject.tag_list
        puts returns_obj.inspect

        expect(returns_obj.tags).to eq(%w[Dogs Pets Puma Animals])
      end
    end
  end

  #==============================================================================
  # PetsUsingSelfDescribingClassesController is a demonstration of how
  # responses can be described using manual generation of a property description
  # array
  #==============================================================================


  describe PetsUsingSelfDescribingClassesController do

    describe "PetsController#pets_described_as_class" do
      subject do
        desc._methods[:pets_described_as_class]
      end

      it "returns code 200 with array of entries of the format {'pet_name', 'animal_type'}" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(true)

        expect(returns_obj).to match_field_structure([:pet_name, :animal_type])
      end

      it 'has the response described in the swagger' do
        response = swagger_response_for('/pets_described_as_class')
        expect(response[:description]).to eq("list of pets")

        schema = response[:schema]
        expect(schema[:type]).to eq("array")

        a_schema = schema[:items]
        expect(a_schema).to have_field(:pet_name, 'string', {:description => 'Name of pet', :required => false})
        expect(a_schema).to have_field(:animal_type, 'string', {:description => 'Type of pet', :enum => %w[dog cat iguana kangaroo]})
      end
    end


    describe "PetsController#pets_with_measurements_described_as_class" do
      subject do
        desc._methods[:pets_with_measurements_described_as_class]
      end

      it "returns code 200 with spread out 'pet' and encapsulated 'pet_measurements'" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name,
                                                      :animal_type,
                                                      {:pet_measurements => [:weight, :height, :num_legs]}
                                                     ])
      end

      it 'has the 200 response described in the swagger' do
        response = swagger_response_for('/pets_with_measurements_described_as_class/{id}', 200)
        expect(response[:description]).to eq('measurements of the pet')

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:required => false})
        expect(schema).to have_field(:animal_type, 'string')
        expect(schema).to have_field(:pet_measurements, 'object')

        pm_schema = schema[:properties][:pet_measurements]
        expect(pm_schema).to have_field(:weight, 'number', {:description => "Weight in pounds"})
        expect(pm_schema).to have_field(:height, 'number', {:description => "Height in inches"})
        expect(pm_schema).to have_field(:num_legs, 'number', {:description => "Number of legs", :required => false})
      end
    end

    describe "PetsController#pets_with_many_measurements_as_class" do
      subject do
        desc._methods[:pets_with_many_measurements_as_class]
      end

      it "returns code 200 with pet_name (string) and many_pet_measurements (array of objects)" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        puts returns_obj.to_json
        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name,
                                                      {:many_pet_measurements => [:weight, :height]}
                                                     ])
      end


      it 'has the 200 response described in the swagger' do
        response = swagger_response_for('/pets_with_many_measurements_as_class/{id}', 200)
        expect(response[:description]).to eq('measurements of the pet')

        schema = response[:schema]
        expect(schema).to have_field(:pet_name, 'string', {:required => false})
        expect(schema).to have_field(:many_pet_measurements, 'array')

        pm_schema = schema[:properties][:many_pet_measurements][:items]
        expect(pm_schema).to have_field(:weight, 'number', {:description => "Weight in pounds"})
        expect(pm_schema).to have_field(:height, 'number', {:description => "Height in inches"})
      end
    end

  end


  #=========================================================
  # PetsUsingAutoViewsController is a demonstration of how
  # responses can be described using logic
  #=========================================================

  describe PetsUsingAutoViewsController do

    describe "PetsController#pet_described_using_automated_view" do
      subject do
        desc._methods[:pet_described_using_automated_view]
      end

      it "returns code 200 with array of entries of the format {'pet_name', 'animal_type'}" do
        returns_obj = subject.returns.detect{|e| e.code == 200 }

        expect(returns_obj.code).to eq(200)
        expect(returns_obj.is_array?).to eq(false)

        expect(returns_obj).to match_field_structure([:pet_name, :animal_type, :age])
      end

      it 'has the response described in the swagger' do
        response = swagger_response_for('/pet_described_using_automated_view/{id}')
        expect(response[:description]).to eq("like Pet, but different")

        schema = response[:schema]
        expect(schema[:type]).to eq("object")

        expect(schema).to have_field(:pet_name, 'string', {:required => true})
        expect(schema).to have_field(:animal_type, 'string', {:required => true})
        expect(schema).to have_field(:age, 'number', {:required => true})
      end
    end
  end


end
