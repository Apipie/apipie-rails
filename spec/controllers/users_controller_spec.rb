require 'spec_helper'

describe UsersController do
  
  describe "resource" do
    it "should be described" do
      a = Restapi.get_resource_description(UsersController)
      
      #puts Restapi.method_descriptions['users#show'].inspect
      a._short_description.should eq('Site members')
      a._methods.count.should == 4
      a._methods.should include("users#show")
      a._methods.should include("users#create")
      a._methods.should include("users#index")
      a._methods.should include("users#two_urls")
      md = a._params[:id]
      md.should_not be(nil)
      md.name.should eq(:id)
      md.desc.should eq("\n<p>User ID</p>\n")
      md.required.should eq(false)
      md.validator.class.should eq(Restapi::Validator::TypeValidator)
      a._id.should eq('users')
      a._path.should eq('/users')
      a._version.should eq('1.0 - 3.4.2012')
      a._name.should eq('Members')
    end
  end

  describe "GET show" do

    it "find a user with id" do
      get :show, :id => 5, :session => "secret_hash"
      
      assert_response :success
    end

    it "throw ArgumentError if some required parameter missing" do
      lambda { get :show, :id => 5 }.should raise_error(ArgumentError)
    end
    
    it "responds with status 401 if session is wrong" do
      get :show, :id => 5, :session => "bad_hash"
      assert_response 401
    end

    it "should be annotated" do
      
      a = Restapi.get_method_description(UsersController, :show)
      b = Restapi[UsersController, :show]
      a.should eq(b)

      a.method.should eq(:show)
      a.resource.should eq('users')
      a.errors[0].code.should eq(401)
      a.errors[0].description.should eq("Unauthorized")
      a.errors[1].code.should eq(404)
      a.errors[1].description.should eq("Not Found")

      a.apis.count.should == 1
      a.apis.first.short_description.should eq("Show user profile")
      a.apis.first.api_url.should
        eq("#{Restapi.configuration.api_base_url}/users/:id")
      a.apis.first.http_method.should eq("GET")

      param = a.params[:session]
      param.required.should eq(true)
      param.desc.should eq("\n<p>user is logged in</p>\n")
      param.validator.class.should be(Restapi::Validator::TypeValidator)
      param.validator.instance_variable_get("@type").should eq(String)
      
      param = a.params[:float_param]
      param.required.should eq(false)
      param.desc.should eq("\n<p>float param</p>\n")
      param.validator.class.should be(Restapi::Validator::TypeValidator)
      param.validator.instance_variable_get("@type").should eq(Float)

      param = a.params[:id]
      param.required.should eq(true)
      param.desc.should eq("\n<p>user id</p>\n")
      param.validator.class.should be(Restapi::Validator::TypeValidator)
      param.validator.instance_variable_get("@type").should eq(Integer)

      param = a.params[:regexp_param]
      param.desc.should eq("\n<p>regexp param</p>\n")
      param.required.should eq(false)
      param.validator.class.should be(Restapi::Validator::RegexpValidator)
      param.validator.instance_variable_get("@regexp").should
        eq(/^[0-9]* years/)

      param = a.params[:array_param]
      param.desc.should eq("\n<p>array validator</p>\n")
      param.validator.class.should be(Restapi::Validator::ArrayValidator)
      param.validator.instance_variable_get("@array").should
        eq([100, "one", "two", 1, 2])

      param = a.params[:proc_param]
      param.desc.should eq("\n<p>proc validator</p>\n")
      param.validator.class.should be(Restapi::Validator::ProcValidator)
      
      a.full_description.length.should be > 400
    end
    
    it "should yell ArgumentError if id is not a number" do
      lambda { 
        get :show, 
            :id => "not a number", 
            :session => "secret_hash"
      }.should raise_error(ArgumentError)
    end
    
    it "should yell ArgumentError if float_param is not a float" do
      lambda { 
        get :show, 
            :id => 5,
            :session => "secret_hash",
            :float_param => "234.2.34"
      }.should raise_error(ArgumentError)
      
      lambda { 
        get :show, 
            :id => 5, 
            :session => "secret_hash", 
            :float_param => "no float here"
      }.should raise_error(ArgumentError)
    end

    it "should understand float validator" do
      get :show, :id => 5, :session => "secret_hash", :float_param => "234.34"
      assert_response :success
      get :show, :id => 5, :session => "secret_hash", :float_param => "234"
      assert_response :success
    end
    
    it "should understand regexp validator" do
      get :show,
          :id => 5,
          :session => "secret_hash",
          :regexp_param => "24 years"
      assert_response :success
    end
    
    it "should validate with regexp validator" do
      lambda {
        get :show,
            :id => 5, 
            :session => "secret_hash",
            :regexp_param => "ten years"
      }.should raise_error(ArgumentError)
    end
    
    it "should validate with array validator" do
      get :show, :id => 5, :session => "secret_hash", :array_param => "one"
      assert_response :success
      get :show, :id => 5, :session => "secret_hash", :array_param => "two"
      assert_response :success
      get :show, :id => 5, :session => "secret_hash", :array_param => 1
      assert_response :success
      get :show, :id => 5, :session => "secret_hash", :array_param => "2"
      assert_response :success
    end
    
    it "should raise ArgumentError with array validator" do
      lambda { 
        get :show,
            :id => 5,
            :session => "secret_hash",
            :array_param => "blabla"
      }.should raise_error(ArgumentError)
      
      lambda {
        get :show, 
            :id => 5,
            :session => "secret_hash",
            :array_param => 3
      }.should raise_error(ArgumentError)
    end
    
    it "should validate with Proc validator" do
      lambda {
        get :show,
            :id => 5,
            :session => "secret_hash",
            :proc_param => "asdgsag"
      }.should raise_error(ArgumentError)
      
      get :show,
          :id => 5,
          :session => "secret_hash",
          :proc_param => "param value"
      assert_response :success
    end
    
  end

  describe "POST create" do
    
    it "should understand hash validator" do
      post :create,
           :user => { 
             :username => "root",
             :password => "12345",
             :membership => "standard"
           }
      assert_response :success

      a = Restapi[UsersController, :create]
      a.apis.count.should == 1
      api = a.apis.first
      api.short_description.should eq("Create user")
      api.api_url.should eq("/api/users")
      api.http_method.should eq("POST")

      lambda {
        post :create,
             :user => {
               :username => "root",
               :password => "12345",
               :membership => "____"
              }
      }.should raise_error(ArgumentError)

      lambda {
        post :create,
             :user => { :username => "root" }
      }.should raise_error(ArgumentError)

      post :create, 
           :user => { :username => "root", :password => "pwd" }
      assert_response :success

    end

  end

  describe 'two_urls' do

    it "should store all api method description" do
      method_description = Restapi[UsersController, :two_urls]
      method_description.class.should be(Restapi::MethodDescription)
      method_description.apis.count.should == 2
      apis = method_description.apis
      a1 = apis.first
      a2 = apis.second
      
      a1.short_description.should eq('Get company users')
      a1.api_url.should eq('/api/company_users')
      a1.http_method.should eq('GET')
      a2.short_description.should eq('Get users working in given company')
      a2.api_url.should eq('/api/company/:id/users')
      a2.http_method.should eq('GET')
    end
  
    it "should be described by valid json" do
       json_hash = {
        :errors => [],
        :doc_url => "#{Restapi.configuration.doc_base_url}#users/two_urls",
        :full_description => '',
        :params => [{
          :description => "\n<p>Authorization</p>\n",
          :required => false,
          :validator => "Parameter has to be String.",
          :name => :oauth
       },{
          :description => "\n<p>Param description for all methods</p>\n",
          :required=>false,
          :validator=>"TODO",
          :name=>:resource_param
        },{
          :description => "\n<p>Company ID</p>\n",
          :required => false,
          :validator => "Parameter has to be Integer.",
          :name => :id
        }],
        :name => :two_urls,
        :apis => [
          {
            :http_method => 'GET',
            :short_description => 'Get company users',
            :api_url => "#{Restapi.configuration.api_base_url}/company_users"
          },{
            :http_method => 'GET',
            :short_description => 'Get users working in given company',
            :api_url =>"#{Restapi.configuration.api_base_url}/company/:id/users"
          }
        ]
      }
      
      Restapi[UsersController, :two_urls].to_json.should eq(json_hash)
    end

  end

end
