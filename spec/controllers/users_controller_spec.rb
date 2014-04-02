require 'spec_helper'

def compare_hashes(h1, h2)
  if h1.is_a? String
    h1.should eq(h2)
  else
    h1.each do |key, val|
      if val.is_a? Hash
        compare_hashes val, h2[key]
      elsif val.is_a? Array
        val.each_with_index do |v, i|
          compare_hashes val[i], h2[key][i]
        end
      else
        val.should eq(h2[key])
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

    it "should contain all resource methods" do
      methods = subject._methods
      methods.keys.should include(:show)
      methods.keys.should include(:index)
      methods.keys.should include(:create)
      methods.keys.should include(:update)
      methods.keys.should include(:two_urls)
    end

    it "should contain info about resource" do
      subject._short_description.should eq('Site members')
      subject._id.should eq('users')
      subject._path.should eq('/users')
      subject._version.should eq('development')
      subject._name.should eq('Users')
      subject._formats.should eq(['json'])
    end

    it "should contain params defined on resource level" do
      subject._params_args.count.should == 2
      name, type, options = subject._params_args.first
      name.should == :id
      type.should == Fixnum
      options.should == {:required=>false, :desc=>"User ID"}
    end
  end

  describe "validators" do

    context "validations are disabled" do
      before do
        Apipie.configuration.validate = false
        Apipie.configuration.validate_value = true
        Apipie.configuration.validate_presence = true
      end

      it "should reply to valid request" do
        get :show, :id => '5', :session => "secret_hash"
        assert_response :success
      end

      it "should pass if required parameter is missing" do
        lambda { get :show, :id => 5 }.should_not raise_error
      end

    end

    context "only presence validations are enabled" do
      before do
        Apipie.configuration.validate = true
        Apipie.configuration.validate_value = false
        Apipie.configuration.validate_presence = true
      end

      it "should reply to valid request" do
        lambda { get :show, :id => 5, :session => "secret_hash" }.should_not raise_error
        assert_response :success
      end

      it "should fail if required parameter is missing" do
        lambda { get :show, :id => 5 }.should raise_error(Apipie::ParamMissing, /\bsession\b/)
      end

      it "should pass if required parameter has wrong type" do
        lambda { get :show, :id => 5, :session => "secret_hash" }.should_not raise_error
        lambda { get :show, :id => "ten", :session => "secret_hash" }.should_not raise_error
      end

    end


    context "validations are enabled" do
      before do
        Apipie.configuration.validate = true
        Apipie.configuration.validate_value = true
        Apipie.configuration.validate_presence = true
      end

      it "should reply to valid request" do
        get :show, :id => '5', :session => "secret_hash"
        assert_response :success
      end

      it "should work with nil value for a required hash param" do
        expect {
          get :show, :id => '5', :session => "secret_hash", :hash_param => {:dummy_hash => nil}
        }.to raise_error(Apipie::ParamInvalid, /dummy_hash/)
        assert_response :success
      end

      it "should fail if required parameter is missing" do
        lambda { get :show, :id => 5 }.should raise_error(Apipie::ParamMissing, /\bsession\b/)
      end

      it "should work with custom Type validator" do
        lambda {
          get :show,
              :id => "not a number",
              :session => "secret_hash"
        }.should raise_error(Apipie::ParamError, /id/) # old-style error rather than ParamInvalid
      end

      it "should work with Regexp validator" do
        get :show,
            :id => 5,
            :session => "secret_hash",
            :regexp_param => "24 years"
        assert_response :success

        lambda {
          get :show,
              :id => 5,
              :session => "secret_hash",
              :regexp_param => "ten years"
        }.should raise_error(Apipie::ParamInvalid, /regexp_param/)
      end

      it "should work with Array validator" do
        get :show, :id => 5, :session => "secret_hash", :array_param => "one"
        assert_response :success
        get :show, :id => 5, :session => "secret_hash", :array_param => "two"
        assert_response :success
        get :show, :id => 5, :session => "secret_hash", :array_param => '1'
        assert_response :success
        get :show, :id => 5, :session => "secret_hash", :boolean_param => false
        assert_response :success

        lambda {
          get :show,
              :id => 5,
              :session => "secret_hash",
              :array_param => "blabla"
        }.should raise_error(Apipie::ParamInvalid, /array_param/)

        lambda {
          get :show,
              :id => 5,
              :session => "secret_hash",
              :array_param => 3
        }.should raise_error(Apipie::ParamInvalid, /array_param/)
      end

      it "should work with Proc validator" do
        lambda {
          get :show,
              :id => 5,
              :session => "secret_hash",
              :proc_param => "asdgsag"
        }.should raise_error(Apipie::ParamInvalid, /proc_param/)

        get :show,
            :id => 5,
            :session => "secret_hash",
            :proc_param => "param value"
        assert_response :success
      end

      it "should work with Hash validator" do
        post :create, :user => { :name => "root", :pass => "12345", :membership => "standard" }
        assert_response :success

        a = Apipie[UsersController, :create]
        param = a.params_ordered.select {|p| p.name == :user }
        param.count.should == 1
        param.first.validator.class.should eq(Apipie::Validator::HashValidator)
        hash_params = param.first.validator.params_ordered
        hash_params.count.should == 4
        hash_params[0].name == :name
        hash_params[1].name == :pass
        hash_params[2].name == :membership

        lambda {
          post :create, :user => { :name => "root", :pass => "12345", :membership => "____" }
        }.should raise_error(Apipie::ParamInvalid, /membership/)

        lambda {
          post :create, :user => { :name => "root" }
        }.should raise_error(Apipie::ParamMissing, /pass/)

        lambda {
          post :create, :user => "a string is not a hash"
        }.should raise_error(Apipie::ParamInvalid, /user/)

        post :create, :user => { :name => "root", :pass => "pwd" }
        assert_response :success
      end

      it "should support Hash validator without specifying keys" do
        params = Apipie[UsersController, :create].to_json[:params]
        params.should include(:name => "facts",
                              :full_name => "facts",
                              :validator => "Must be Hash",
                              :description => "\n<p>Additional optional facts about the user</p>\n",
                              :required => false,
                              :allow_nil => true,
                              :metadata => nil,
                              :show => true,
                              :expected_type => "hash")
      end

      it "should allow nil when allow_nil is set to true" do
        post :create,
             :user => {
               :name => "root",
               :pass => "12345",
               :membership => "standard",
             },
             :facts => nil
        assert_response :success
      end

      describe "nested elements"  do

        context "with valid input" do
          it "should succeed" do
            put :update,
                {
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
          it "should raise an error" do
            expect{
              put :update,
                {
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
                      :comment => {:bad_input => 5}
                    }
                  ]
                }
            }.to raise_error(Apipie::ParamInvalid)
          end
        end
        it "should work with empty array" do
          put :update,
              {
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

  describe "method description" do

    it "should contain basic info about method" do
      a = Apipie[UsersController, :create]
      a.apis.count.should == 1
      a.formats.should eq(['json'])
      api = a.apis.first
      api.short_description.should eq("Create user")
      api.path.should eq("/users")
      api.http_method.should eq("POST")

      b = Apipie.get_method_description(UsersController, :show)
      b.should eq(Apipie[UsersController, :show])
      b.method.should eq('show')
      b.resource._id.should eq('users')

      b.apis.count.should == 1
      b.formats.should eq(['json', 'jsonp'])
      api = b.apis.first
      api.short_description.should eq("Show user profile")
      api.path.should eq("/users/:id")
      api.http_method.should eq("GET")
      b.full_description.length.should be > 400
    end

    context "contain :see option" do

      context "the key is valid" do
        it "should contain reference to another method" do
          api = Apipie[UsersController, :see_another]
          see = api.see.first
          see.see_url.should == Apipie[UsersController, :create].doc_url
          see.link.should == 'development#users#create'
          see.description.should == 'development#users#create'

          see_with_desc = api.see.last
          see_with_desc.see_url.should == Apipie[UsersController, :index].doc_url
          see_with_desc.link.should == 'development#users#index'
          see_with_desc.description.should == 'very interesting method reference'

          Apipie['development#users#see_another'].should eq(Apipie[UsersController, :see_another])
        end
      end

      context "the key is not valid" do
        it "should raise exception" do
          api = Apipie[UsersController, :see_another]
          api.instance_variable_set :@see, [Apipie::SeeDescription.new(['doesnot#exist'])]
          lambda {
            api.see.first.see_url
          }.should raise_error(ArgumentError, /does not exist/)
          api.instance_variable_set :@see, []
        end
      end
    end

    it "should contain possible errors description" do
      a = Apipie.get_method_description(UsersController, :show)

      a.errors[0].code.should eq(500)
      a.errors[0].description.should include("crashed")
      a.errors[1].code.should eq(401)
      a.errors[1].description.should eq("Unauthorized")
      a.errors[2].code.should eq(404)
      a.errors[2].description.should eq("Not Found")
    end

    it "should contain all params description" do
      a = Apipie.get_method_description(UsersController, :show)
      a.params.count.should == 11
      a.instance_variable_get('@params_ordered').count.should == 9
    end

    it "should contain all api method description" do
      method_description = Apipie[UsersController, :two_urls]
      method_description.class.should be(Apipie::MethodDescription)
      method_description.apis.count.should == 2
      a1, a2 = method_description.apis

      a1.short_description.should eq('Get company users')
      a1.path.should eq('/company_users')
      a1.http_method.should eq('GET')

      a2.short_description.should eq('Get users working in given company')
      a2.path.should eq('/company/:id/users')
      a2.http_method.should eq('GET')
    end

    it "should be described by valid json" do
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
                     :validator=>"Must be String",
                     :description=>"\n<p>Authorization</p>\n",
                     :name=>"oauth",
                     :show=>true,
                     :expected_type=>"string"},
                    {:validator=>"Must be a Hash",
                     :description=>"\n<p>Deprecated parameter not documented</p>\n",
                     :expected_type=>"hash",
                     :allow_nil=>false,
                     :name=>"legacy_param",
                     :required=>false,
                     :full_name=>"legacy_param",
                     :show=>false,
                     :params=>
                      [{:validator=>"Must be a Hash",
                        :description=>"\n<p>Param description for all methods</p>\n",
                        :expected_type=>"hash",
                        :allow_nil=>false,
                        :name=>"resource_param",
                        :required=>false,
                        :full_name=>"resource_param",
                        :show=>true,
                        :params=>
                        [{:required=>true,
                          :allow_nil => false,
                          :validator=>"Must be String",
                          :description=>"\n<p>Username for login</p>\n",
                          :name=>"ausername", :full_name=>"resource_param[ausername]",
                          :show=>true,
                          :expected_type=>"string"},
                         {:required=>true,
                          :allow_nil => false,
                          :validator=>"Must be String",
                          :description=>"\n<p>Password for login</p>\n",
                          :name=>"apassword", :full_name=>"resource_param[apassword]",
                          :show=>true,
                          :expected_type=>"string"}
                        ]}
                      ]
                    },
                    {:required=>false, :validator=>"Parameter has to be Integer.",
                     :allow_nil => false,
                     :description=>"\n<p>Company ID</p>\n",
                     :name=>"id", :full_name=>"id",
                     :show=>true,
                     :expected_type=>"numeric"},
       ],
        :name => 'two_urls',
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

    it "should be able to load examples from yml file" do
      Apipie.get_method_description(UsersController, :show).examples.should == [<<EOS1, <<EOS2].map(&:chomp)
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
      it "should be able to load document from markup file" do
        Apipie.get_method_description(UsersController, :desc_from_file).full_description.should include("description from document")
      end
    end
  end

  describe "param description" do

    it "should contain all specified information" do
      a = Apipie.get_method_description(UsersController, :show)

      param = a.params[:session]
      param.required.should eq(true)
      param.desc.should eq("\n<p>user is logged in</p>\n")
      param.validator.class.should be(Apipie::Validator::TypeValidator)
      param.validator.instance_variable_get("@type").should eq(String)

      param = a.params[:id]
      param.required.should eq(true)
      param.desc.should eq("\n<p>user id</p>\n")
      param.validator.class.should be(Apipie::Validator::IntegerValidator)
      param.validator.instance_variable_get("@type").should eq(Integer)

      param = a.params[:regexp_param]
      param.desc.should eq("\n<p>regexp param</p>\n")
      param.required.should eq(false)
      param.validator.class.should be(Apipie::Validator::RegexpValidator)
      param.validator.instance_variable_get("@regexp").should
        eq(/^[0-9]* years/)

      param = a.params[:array_param]
      param.desc.should eq("\n<p>array validator</p>\n")
      param.validator.class.should be(Apipie::Validator::ArrayValidator)
      param.validator.instance_variable_get("@array").should
        eq([100, "one", "two", 1, 2])

      param = a.params[:proc_param]
      param.desc.should eq("\n<p>proc validator</p>\n")
      param.validator.class.should be(Apipie::Validator::ProcValidator)

      param = a.params[:briefer_dsl]
      param.desc.should eq("\n<p>You dont need :desc =&gt; from now</p>\n")
      param.validator.class.should be(Apipie::Validator::TypeValidator)
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
        Apipie.get_method_description(UsersController, :ignore).should be_nil

        Apipie.define_method_description(UsersController, :dont_ignore, dsl_data)
        Apipie.get_method_description(UsersController, :dont_ignore).should_not be_nil
      end
    end

    describe "ignored controller" do
      before do
        Apipie.configuration.ignored = %w[IgnoredController]
      end

      it "skips the listed controller from the documentation" do
        Apipie.define_method_description(IgnoredController, :ignore, dsl_data)
        Apipie.get_method_description(IgnoredController, :ignore).should be_nil
        Apipie.define_method_description(IgnoredController, :ignore, dsl_data)
        Apipie.get_method_description(IgnoredController, :ignore).should be_nil
      end
    end
  end

  describe "Parameter processing / extraction" do
    before do
      Apipie.configuration.process_params = true
    end

    it "process correctly the parameters" do
      post :create, {:user => {:name => 'dummy', :pass => 'dummy', :membership => 'standard'}, :facts => nil}

      expect(assigns(:api_params).with_indifferent_access).to eq({:user => {:name=>"dummy", :pass=>"dummy", :membership=>"standard"}, :facts => nil}.with_indifferent_access)
    end

    it "ignore not described parameters" do
      post :create, {:user => {:name => 'dummy', :pass => 'dummy', :membership => 'standard', :id => 0}}

      expect(assigns(:api_params).with_indifferent_access).to eq({:user => {:name=>"dummy", :pass=>"dummy", :membership=>"standard"}}.with_indifferent_access)
    end

    after do
      Apipie.configuration.process_params = false
    end
  end
end
