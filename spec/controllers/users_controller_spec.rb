require 'spec_helper'

def compare_hashes(h1, h2)
  if h1.is_a? String
    expect(h1).to eq(h2)
  else
    h1.each do |key, val|
      case val
      when Hash
        compare_hashes val, h2[key]
      when Array
        val.each_with_index do |v, i|
          compare_hashes val[i], h2[key][i]
        end
      else
        expect(val).to eq(h2[key])
      end
    end
  end
end

describe UsersController do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  describe "resource description" do
    subject do
      Apipie.get_resource_description(UsersController, Apipie.configuration.default_version)
    end

    it "contains all resource methods" do
      methods = subject._methods
      expect(methods.keys).to include(:show)
      expect(methods.keys).to include(:create_route)
      expect(methods.keys).to include(:index)
      expect(methods.keys).to include(:create)
      expect(methods.keys).to include(:update)
      expect(methods.keys).to include(:two_urls)
      expect(methods.keys).to include(:action_with_headers)
      expect(methods.keys).to include(:multiple_required_params)
    end

    it "contains info about resource" do
      expect(subject._short_description).to eq('Site members')
      expect(subject._id).to eq('users')
      expect(subject._path).to eq('/users')
      expect(subject._version).to eq('development')
      expect(subject._name).to eq('Users')
      expect(subject._formats).to eq(['json'])
    end

    it "contains params defined on resource level" do
      expect(subject._params_args.count).to eq(2)
      name, type, options = subject._params_args.first
      expect(name).to eq(:id)
      expect(type).to eq(Integer)
      expect(options).to eq({:required=>false, :desc=>"User ID"})
    end
  end

  describe "validators" do

    context "validations are disabled" do
      before do
        Apipie.configuration.validate = false
        Apipie.configuration.validate_value = true
        Apipie.configuration.validate_presence = true
      end

      it "replies to valid request" do
        get :show, :params => { :id => '5', :session => "secret_hash" }
        assert_response :success
      end

      it "passes if required parameter is missing" do
        expect { get :show, :params => { :id => 5 } }.not_to raise_error
      end

    end

    context "validations are enabled" do
      def reload_controllers
        controllers_dirname = File.expand_path('../dummy/app/controllers', File.dirname(__FILE__))
        Dir.glob("#{controllers_dirname}/**/*") { |file| load(file) if File.file?(file) }
      end

      shared_examples "validates correctly" do

        context "only presence validations are enabled" do
          before do
            Apipie.configuration.validate_value = false
            Apipie.configuration.validate_presence = true
            Apipie.configuration.validate_key = false
          end

          it "replies to valid request" do
            expect { get :show, :params => { :id => 5, :session => "secret_hash" }}.not_to raise_error
            assert_response :success
          end

          it "fails if required parameter is missing" do
            expect { get :show, :params => { :id => 5 }}.to raise_error(Apipie::ParamMissing, /session_parameter_is_required/)
          end

          it "fails if multiple required parameters are missing" do
            expect { get :multiple_required_params }.to raise_error(Apipie::ParamMultipleMissing, /required_param1.*\n.*required_param2|required_param2.*\n.*required_parameter1/)
          end

          it "passes if required parameter has wrong type" do
            expect { get :show, :params => { :id => 5 , :session => "secret_hash" }}.not_to raise_error
            expect { get :show, :params => { :id => "ten" , :session => "secret_hash" }}.not_to raise_error
          end

        end

        context "key validations are enabled" do
          before do
            Apipie.configuration.validate_value = false
            Apipie.configuration.validate_presence = true
            Apipie.configuration.validate_key = true
          end

          it "replies to valid request" do
            expect { get :show, :params => { :id => 5, :session => 'secret_hash' }}.not_to raise_error
            assert_response :success
          end

          it "fails if extra parameter is passed in" do
            expect { get :show, :params => { :id => 5 , :badparam => 'badfoo', :session => "secret_hash" }}.to raise_error(Apipie::UnknownParam, /\bbadparam\b/)
          end
        end

        context "key validations are enabled and skip on non-validated keys" do
          before do
            Apipie.configuration.validate_value = false
            Apipie.configuration.validate_presence = true
            Apipie.configuration.validate_key = true
            Apipie.configuration.action_on_non_validated_keys = :skip
          end

          it "replies to valid request" do
            expect { get :show, :params => { :id => 5, :session => 'secret_hash' }}.not_to raise_error
            assert_response :success
          end

          it "deletes the param and not fail if an extra parameter is passed." do
            expect { get :show, :params => { :id => 5 , :badparam => 'badfoo', :session => "secret_hash" }}.not_to raise_error
            expect(controller.params.as_json).to eq({"session"=>"secret_hash", "id"=>"5", "controller"=>"users", "action"=>"show"})
          end

          after do
            Apipie.configuration.action_on_non_validated_keys = :raise
          end
        end

        context "presence and value validations are enabled" do
          before do
            Apipie.configuration.validate_value = true
            Apipie.configuration.validate_presence = true
            Apipie.configuration.validate_key = false
          end

          it "replies to valid request" do
            get :show, :params => { :id => '5', :session => "secret_hash" }
            assert_response :success
          end

          it "works with nil value for a required hash param" do
            expect do
              get :show, :params => { :id => '5', :session => "secret_hash", :hash_param => {:dummy_hash => nil} }
            end.to raise_error(Apipie::ParamInvalid, /dummy_hash/)
            assert_response :success
          end

          it "fails if required parameter is missing" do
            expect { get :show, :params => { :id => 5 }}.to raise_error(Apipie::ParamMissing, /session_parameter_is_required/)
          end

          # old-style error rather than ParamInvalid
          it "works with custom Type validator" do
            expect do
              get :show,
                  :params => { :id => "not a number", :session => "secret_hash" }
            end.to raise_error(Apipie::ParamError, /id/)
          end

          it "works with Regexp validator" do
            get :show, :params => { :id => 5, :session => "secret_hash", :regexp_param => "24 years" }
            assert_response :success

            expect do
              get :show, :params => { :id => 5,
                                      :session => "secret_hash",
                                      :regexp_param => "ten years" }
            end.to raise_error(Apipie::ParamInvalid, /regexp_param/)
          end

          it "works with Array validator" do
            get :show, :params => { :id => 5, :session => "secret_hash", :array_param => "one" }
            assert_response :success
            get :show, :params => { :id => 5, :session => "secret_hash", :array_param => "two" }
            assert_response :success
            get :show, :params => { :id => 5, :session => "secret_hash", :array_param => '1' }
            assert_response :success

            expect do
              get :show, :params => { :id => 5,
                                      :session => "secret_hash",
                                      :array_param => "blabla" }
            end.to raise_error(Apipie::ParamInvalid, /array_param/)

            expect do
              get :show, :params => {
                :id => 5,
                :session => "secret_hash",
                :array_param => 3 }
            end.to raise_error(Apipie::ParamInvalid, /array_param/)
          end

          it "works with Proc validator" do
            expect do
              get :show,
                  :params => {
                    :id => 5,
                    :session => "secret_hash",
                    :proc_param => "asdgsag" }
            end.to raise_error(Apipie::ParamInvalid, /proc_param/)

            get :show,
                :params => {
                  :id => 5,
                  :session => "secret_hash",
                  :proc_param => "param value"}
            assert_response :success
          end

          it "works with Hash validator" do
            post :create, params: { :user => { :name => "root", :pass => "12345", :membership => "standard" } }
            assert_response :success

            a = Apipie[UsersController, :create]
            param = a.params_ordered.select {|p| p.name == :user }
            expect(param.count).to eq(1)
            expect(param.first.validator.class).to eq(Apipie::Validator::HashValidator)
            hash_params = param.first.validator.params_ordered
            expect(hash_params.count).to eq(4)
            hash_params[0].name == :name
            hash_params[1].name == :pass
            hash_params[2].name == :membership

            expect do
              post :create, :params => { :user => { :name => "root", :pass => "12345", :membership => "____" } }
            end.to raise_error(Apipie::ParamInvalid, /membership/)

            # Should include both pass and name
            expect do
              post :create, :params => { :user => { :membership => "standard" } }
            end.to raise_error(Apipie::ParamMultipleMissing, /pass.*\n.*name|name.*\n.*pass/)

            expect do
              post :create, :params => { :user => { :name => "root" } }
            end.to raise_error(Apipie::ParamMissing, /pass/)

            expect do
              post :create, :params => { :user => "a string is not a hash" }
            end.to raise_error(Apipie::ParamInvalid, /user/)

            post :create, :params => { :user => { :name => "root", :pass => "pwd" } }
            assert_response :success
          end

          it "supports Hash validator without specifying keys" do
            params = Apipie[UsersController, :create].to_json[:params]
            expect(params).to include(:name => "facts",
                                  :full_name => "facts",
                                  :validator => "Must be a Hash",
                                  :description => "\n<p>Additional optional facts about the user</p>\n",
                                  :required => false,
                                  :allow_nil => true,
                                  :allow_blank => false,
                                  :metadata => nil,
                                  :show => true,
                                  :deprecated => false,
                                  :expected_type => "hash",
                                  :validations => [])
          end

          it "allows nil when allow_nil is set to true" do
            post :create,
                 :params => {
                   :user => {
                     :name => "root",
                     :pass => "12345",
                     :membership => "standard",
                   },
                   :facts => { :test => 'test' }
                 }
            assert_response :success
          end

          it "allows blank when allow_blank is set to true" do
            post :create,
              :params => {
                :user => {
                  :name => "root",
                  :pass => "12345",
                  :membership => "standard"
                },
                :age => ""
              }
            assert_response :success
          end

          describe "nested elements"  do

            context "with valid input" do
              it "succeeds" do
                put :update,
                    :params => {
                      :id => 5,
                      :user => {
                        :name => "root",
                        :pass => "12345"
                      },
                      :comments => [
                        {
                          :comment => 'comment1'
                        },
                        {
                          :comment => 'comment2'
                        }
                      ]
                    }

                assert_response :success
              end
            end
            context "with bad input" do
              it "raises an error" do
                expect do
                  put :update,
                      :params => {
                        :id => 5,
                        :user => {
                          :name => "root",
                          :pass => "12345"
                        },
                        :comments => [
                          {
                            :comment => {:bad_input => 4}
                          },
                          {
                            :comment => {:bad_input => 5}
                          }
                        ]
                      }
                end.to raise_error(Apipie::ParamInvalid)
              end
            end
            it "works with empty array" do
              put :update,
                  :params => {
                    :id => 5,
                    :user => {
                      :name => "root",
                      :pass => "12345"
                    },
                    :comments => [
                    ]
                  }

              assert_response :success
            end
          end

        end
      end

      context "using configuration.validate = true" do
        before :all do
          Apipie.configuration.validate = true
          reload_controllers
        end

        it_behaves_like "validates correctly"
      end

      context "using configuration.validate = :implicitly" do
        before :all do
          Apipie.configuration.validate = :implicitly
          reload_controllers
        end

        it_behaves_like "validates correctly"
      end

      context "using configuration.validate = :explicitly" do
        before :all do
          Apipie.configuration.validate = :explicitly
          reload_controllers
        end

        it_behaves_like "validates correctly"
      end
    end

  end

  describe "method description" do

    it "contains basic info about method" do
      a = Apipie[UsersController, :create]
      expect(a.apis.count).to eq(1)
      expect(a.formats).to eq(['json'])
      api = a.apis.first
      expect(api.short_description).to eq("Create user")
      expect(api.path).to eq("/users")
      expect(api.http_method).to eq("POST")

      b = Apipie.get_method_description(UsersController, :show)
      expect(b).to eq(Apipie[UsersController, :show])
      expect(b.method).to eq('show')
      expect(b.resource._id).to eq('users')

      expect(b.apis.count).to eq(1)
      expect(b.formats).to eq(%w[json jsonp])
      api = b.apis.first
      expect(api.short_description).to eq("Show user profile")
      expect(api.path).to eq("/users/:id")
      expect(api.http_method).to eq("GET")
      expect(b.full_description.length).to be > 400
    end

    context "Using routes.rb" do
      it "contains basic info about method" do
        a = Apipie[UsersController, :create_route]
        expect(a.apis.count).to eq(1)
        expect(a.formats).to eq(['json'])
        api = a.apis.first
        expect(api.short_description).to eq("Create user")
        expect(api.path).to eq("/api/users/create_route")
        expect(api.from_routes).to be_truthy
        expect(api.http_method).to eq("POST")
      end
    end

    context "contain :see option" do

      context "the key is valid" do
        it "contains reference to another method" do
          api = Apipie[UsersController, :see_another]
          expect(api.show).to be false
          see = api.see.first
          expect(see.see_url).to eql Apipie[UsersController, :create].doc_url
          expect(see.link).to eql 'development#users#create'
          expect(see.description).to eql 'development#users#create'

          see_with_desc = api.see.last
          expect(see_with_desc.see_url).to eql Apipie[UsersController, :index].doc_url
          expect(see_with_desc.link).to eql 'development#users#index'
          expect(see_with_desc.description).to eql 'very interesting method reference'

          expect(Apipie['development#users#see_another']).to eql Apipie[UsersController, :see_another]
        end
      end

      context "the key is not valid" do
        it "raises exception" do
          api = Apipie[UsersController, :see_another]
          api.instance_variable_set :@see, [Apipie::SeeDescription.new(['doesnot#exist'])]
          expect do
            api.see.first.see_url
          end.to raise_error(ArgumentError, /does not exist/)
          api.instance_variable_set :@see, []
        end
      end
    end

    it "contains possible errors description" do
      a = Apipie.get_method_description(UsersController, :show)

      expect(a.errors[0].code).to eq(500)
      expect(a.errors[0].description).to include("crashed")
      expect(a.errors[1].code).to eq(401)
      expect(a.errors[1].description).to eq("Unauthorized")
      expect(a.errors[2].code).to eq(404)
      expect(a.errors[2].description).to eq("Not Found")
    end

    it 'recognizes Rack symbols as error codes' do
      a = Apipie.get_method_description(UsersController, :create)

      error = a.errors.find { |e| e.code == 422 }
      expect(error).to be
      expect(error.description).to include("Unprocessable Entity")
    end

    it "contains all params description" do
      a = Apipie.get_method_description(UsersController, :show)
      expect(a.params.count).to eq(12)
      expect(a.instance_variable_get('@params_ordered').count).to eq(10)
    end

    context 'headers' do
      context 'for methods' do
        let(:expected_required_header) do
          {
            name: :RequredHeaderName,
            description: 'Required header description',
            options: {
              required: true
            }
          }
        end

        let(:expected_optional_header) do
          {
            name: :OptionalHeaderName,
            description: 'Optional header description',
            options: {
              required: false,
              type: "string"
            }
          }
        end

        let(:expected_header_with_default) do
          {
            name: :HeaderNameWithDefaultValue,
            description: 'Header with default value',
            options: {
              required: true,
              default: 'default value'
            }
          }
        end

        it 'contains all headers description in method doc' do
          headers = Apipie.get_method_description(UsersController, :action_with_headers).headers
          expect(headers).to be_an(Array)

          compare_hashes headers[0], expected_required_header
          compare_hashes headers[1], expected_optional_header
          compare_hashes headers[2], expected_header_with_default
        end
      end

      context 'for resource' do
        let(:expected_resource_header) do
          {
            name: :CommonHeader,
            description: 'Common header description',
            options: {
              required: true
            }
          }
        end

        it 'contains all headers description in resource doc' do
          headers = Apipie.get_resource_description(UsersController)._headers
          expect(headers).to be_an(Array)

          compare_hashes headers[0], expected_resource_header
        end
      end
    end

    it "contains all api method description" do
      method_description = Apipie[UsersController, :two_urls]
      expect(method_description.class).to be(Apipie::MethodDescription)
      expect(method_description.apis.count).to eq(2)
      a1, a2 = method_description.apis

      expect(a1.short_description).to eq('Get company users')
      expect(a1.path).to eq('/company_users')
      expect(a1.http_method).to eq('GET')

      expect(a2.short_description).to eq('Get users working in given company')
      expect(a2.path).to eq('/company/:id/users')
      expect(a2.http_method).to eq('GET')
    end

    it "is described by valid json" do
      json = Apipie[UsersController, :two_urls].to_json
      expected_hash = {
        :errors => [{:code=>404, :description=>"Missing", :metadata => {:some => "metadata"}},
                    {:code=>500, :description=>"Server crashed for some <%= reason %>"}],
        :examples => [],
        :doc_url => "#{Apipie.configuration.doc_base_url}/development/users/two_urls",
        :formats=>["json"],
        :full_description => '',
        :params => [{:full_name=>"oauth",
                     :required=>false,
                     :allow_nil => false,
                     :allow_blank => false,
                     :validator=>"Must be a String",
                     :description=>"\n<p>Authorization</p>\n",
                     :name=>"oauth",
                     :show=>true,
                     :deprecated=>false,
                     :expected_type=>"string"},
                    {:validator=>"Must be a Hash",
                     :description=>"\n<p>Deprecated parameter not documented</p>\n",
                     :expected_type=>"hash",
                     :allow_nil=>false,
                     :allow_blank => false,
                     :name=>"legacy_param",
                     :required=>false,
                     :full_name=>"legacy_param",
                     :show=>false,
                     :deprecated=>false,
                     :params=>
                      [{:validator=>"Must be a Hash",
                        :description=>"\n<p>Param description for all methods</p>\n",
                        :expected_type=>"hash",
                        :allow_nil=>false,
                        :allow_blank => false,
                        :name=>"resource_param",
                        :required=>false,
                        :full_name=>"resource_param",
                        :deprecated=>false,
                        :show=>true,
                        :params=>
                        [{:required=>true,
                          :allow_nil => false,
                          :allow_blank => false,
                          :validator=>"Must be a String",
                          :description=>"\n<p>Username for login</p>\n",
                          :name=>"ausername", :full_name=>"resource_param[ausername]",
                          :show=>true,
                          :deprecated=>false,
                          :expected_type=>"string"},
                         {:required=>true,
                          :allow_nil => false,
                          :allow_blank => false,
                          :validator=>"Must be a String",
                          :description=>"\n<p>Password for login</p>\n",
                          :name=>"apassword", :full_name=>"resource_param[apassword]",
                          :show=>true,
                          :deprecated=>false,
                          :expected_type=>"string"}
                        ]}
                      ]
                    },
                    {:required=>false, :validator=>"Parameter has to be Integer.",
                     :allow_nil => false,
                     :allow_blank => false,
                     :description=>"\n<p>Company ID</p>\n",
                     :name=>"id", :full_name=>"id",
                     :show=>true,
                     :deprecated=>false,
                     :expected_type=>"numeric"},
       ],
        :name => 'two_urls',
        :show => true,
        :apis => [
          {
            :http_method => 'GET',
            :short_description => 'Get company users',
            :api_url => "#{Apipie.api_base_url}/company_users"
          },{
            :http_method => 'GET',
            :short_description => 'Get users working in given company',
            :api_url =>"#{Apipie.api_base_url}/company/:id/users"
          }
        ]
      }

      compare_hashes json, expected_hash
    end

  end

  describe "examples" do

    it "is able to load examples from yml file" do
      expect(Apipie.get_method_description(UsersController, :show).examples).to eq [<<EOS1, <<EOS2].map(&:chomp)
GET /users/14?verbose=true
200
{
  "name": "Test User"
}
EOS1
GET /users/15
404
EOS2
    end

    describe "document" do
      it "is able to load document from markup file" do
        expect(Apipie.get_method_description(UsersController, :desc_from_file).full_description).to include("description from document")
      end
    end
  end

  describe "param description" do

    it "contains all specified information" do
      a = Apipie.get_method_description(UsersController, :show)

      param = a.params[:session]
      expect(param.required).to eq(true)
      expect(param.desc).to eq("\n<p>user is logged in</p>\n")
      expect(param.validator.class).to be(Apipie::Validator::TypeValidator)
      expect(param.validator.instance_variable_get("@type")).to eq(String)

      param = a.params[:id]
      expect(param.required).to eq(true)
      expect(param.desc).to eq("\n<p>user id</p>\n")
      expect(param.validator.class).to be(Apipie::Validator::IntegerValidator)
      expect(param.validator.instance_variable_get("@type")).to eq(Integer)

      param = a.params[:regexp_param]
      expect(param.desc).to eq("\n<p>regexp param</p>\n")
      expect(param.required).to eq(false)
      expect(param.validator.class).to be(Apipie::Validator::RegexpValidator)
      expect(param.validator.instance_variable_get("@regexp")).to eq(/^[0-9]* years/)

      param = a.params[:array_param]
      expect(param.desc).to eq("\n<p>array validator</p>\n")
      expect(param.validator.class).to be(Apipie::Validator::EnumValidator)
      expect(param.validator.instance_variable_get("@array")).to eq(%w[100 one two 1 2])

      param = a.params[:proc_param]
      expect(param.desc).to eq("\n<p>proc validator</p>\n")
      expect(param.validator.class).to be(Apipie::Validator::ProcValidator)

      param = a.params[:briefer_dsl]
      expect(param.desc).to eq("\n<p>You dont need :desc =&gt; from now</p>\n")
      expect(param.validator.class).to be(Apipie::Validator::TypeValidator)
    end

  end

  describe "ignored option" do
    class IgnoredController < ApplicationController; end

    after do
      Apipie.configuration.ignored = %w[]
    end

    describe "ignored action" do
      before do
        Apipie.configuration.ignored = %w[UsersController#ignore]
      end

      it "skips the listed  actions from the documentation" do
        Apipie.define_method_description(UsersController, :ignore, dsl_data)
        expect(Apipie.get_method_description(UsersController, :ignore)).to be_nil

        Apipie.define_method_description(UsersController, :dont_ignore, dsl_data)
        expect(Apipie.get_method_description(UsersController, :dont_ignore)).not_to be_nil
      end
    end

    describe "ignored controller" do
      before do
        Apipie.configuration.ignored = %w[IgnoredController]
      end

      it "skips the listed controller from the documentation" do
        Apipie.define_method_description(IgnoredController, :ignore, dsl_data)
        expect(Apipie.get_method_description(IgnoredController, :ignore)).to be_nil
        Apipie.define_method_description(IgnoredController, :ignore, dsl_data)
        expect(Apipie.get_method_description(IgnoredController, :ignore)).to be_nil
      end
    end
  end

  describe "Parameter processing / extraction" do
    before do
      Apipie.configuration.validate = true
      Apipie.configuration.process_params = true
      controllers_dirname = File.expand_path('../dummy/app/controllers', File.dirname(__FILE__))
      Dir.glob("#{controllers_dirname}/**/*") { |file| load(file) if File.file?(file) }
    end

    it "process correctly the parameters" do
      post :create, :params => {:user => {:name => 'dummy', :pass => 'dummy', :membership => 'standard' }, :facts => {:test => 'test'}}

      expect(assigns(:api_params).with_indifferent_access).to eq({:user => {:name=>"dummy", :pass=>"dummy", :membership=>"standard"}, :facts => {:test => 'test'}}.with_indifferent_access)
    end

    it "ignore not described parameters" do
      post :create, :params => {:user => {:name => 'dummy', :pass => 'dummy', :membership => 'standard', :id => 0}}

      expect(assigns(:api_params).with_indifferent_access).to eq({:user => {:name=>"dummy", :pass=>"dummy", :membership=>"standard"}}.with_indifferent_access)
    end

    after do
      Apipie.configuration.process_params = false
    end
  end
end
