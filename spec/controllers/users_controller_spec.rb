require 'spec_helper'

def compare_hashes(h1, h2)
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

describe UsersController do

  describe "resource description" do
    subject { a = Restapi.get_resource_description(UsersController) }

    it "should contain all resource methods" do
      methods = subject._methods
      methods.count.should == 5
      methods.should include("users#show")
      methods.should include("users#create")
      methods.should include("users#index")
      methods.should include("users#two_urls")
    end

    it "should contain info about resource" do
      subject._short_description.should eq('Site members')
      subject._id.should eq('users')
      subject._path.should eq('/users')
      subject._version.should eq('1.0 - 3.4.2012')
      subject._name.should eq('Members')
    end

    it "should contain params defined on resource level" do
      subject._params_ordered.count.should == 2
      p = subject._params_ordered.first
      p.should_not be(nil)
      p.name.should eq(:id)
      p.desc.should eq("\n<p>User ID</p>\n")
      p.required.should eq(false)
      p.validator.class.should eq(Restapi::Validator::IntegerValidator)

      p = subject._params_ordered.second
      p.should_not be(nil)
      p.name.should eq(:resource_param)
      p.desc.should eq("\n<p>Param description for all methods</p>\n")
      p.required.should eq(false)
      p.validator.class.should eq(Restapi::Validator::HashValidator)
    end
  end

  describe "validators" do

    context "validations are disabled" do
      before { Restapi.configuration.validate = false }

      it "should reply to valid request" do
        get :show, :id => '5', :session => "secret_hash"
        assert_response :success
      end

      it "should pass if required parameter is missing" do
        lambda { get :show, :id => 5 }.should_not raise_error
      end

    end


    context "validations are enabled" do
      before { Restapi.configuration.validate = true }

      it "should reply to valid request" do
        get :show, :id => '5', :session => "secret_hash"
        assert_response :success
      end

      it "should fail if required parameter is missing" do
        lambda { get :show, :id => 5 }.should raise_error(ArgumentError, / session /)
      end

      it "should work with Type validator" do
        lambda {
          get :show,
              :id => "not a number",
              :session => "secret_hash"
        }.should raise_error(ArgumentError, / id /)
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
        }.should raise_error(ArgumentError, / regexp_param /)
      end

      it "should work with Array validator" do
        get :show, :id => 5, :session => "secret_hash", :array_param => "one"
        assert_response :success
        get :show, :id => 5, :session => "secret_hash", :array_param => "two"
        assert_response :success
        get :show, :id => 5, :session => "secret_hash", :array_param => 1
        assert_response :success
        get :show, :id => 5, :session => "secret_hash", :boolean_param => false
        assert_response :success

        lambda {
          get :show,
              :id => 5,
              :session => "secret_hash",
              :array_param => "blabla"
        }.should raise_error(ArgumentError, / array_param /)

        lambda {
          get :show,
              :id => 5,
              :session => "secret_hash",
              :array_param => 3
        }.should raise_error(ArgumentError, / array_param /)
      end

      it "should work with Proc validator" do
        lambda {
          get :show,
              :id => 5,
              :session => "secret_hash",
              :proc_param => "asdgsag"
        }.should raise_error(ArgumentError, / proc_param /)

        get :show,
            :id => 5,
            :session => "secret_hash",
            :proc_param => "param value"
        assert_response :success
      end

      it "should work with Hash validator" do
        post :create, :user => { :name => "root", :pass => "12345", :membership => "standard" }
        assert_response :success

        a = Restapi[UsersController, :create]
        param = a.params_ordered.select {|p| p.name == :user }
        param.count.should == 1
        param.first.validator.class.should eq(Restapi::Validator::HashValidator)
        hash_params = param.first.validator.hash_params_ordered
        hash_params.count.should == 3
        hash_params[0].name == :name
        hash_params[1].name == :pass
        hash_params[2].name == :membership

        lambda {
          post :create, :user => { :name => "root", :pass => "12345", :membership => "____" }
        }.should raise_error(ArgumentError, / membership /)

        lambda {
          post :create, :user => { :name => "root" }
        }.should raise_error(ArgumentError, / pass /)

        post :create, :user => { :name => "root", :pass => "pwd" }
        assert_response :success
      end

      it "should support Hash validator without specifying keys" do
        params = Restapi[UsersController, :create].to_json[:params]
        params.should include(:name => "facts",
                              :full_name => "facts",
                              :validator => "Parameter has to be Hash.",
                              :description => "\n<p>Additional optional facts about the user</p>\n",
                              :required => false,
                              :allow_nil => true,
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

    end
  end

  describe "method description" do

    it "should contain basic info about method" do
      a = Restapi[UsersController, :create]
      a.apis.count.should == 1
      api = a.apis.first
      api.short_description.should eq("Create user")
      api.api_url.should eq("/api/users")
      api.http_method.should eq("POST")

      b = Restapi.get_method_description(UsersController, :show)
      b.should eq(Restapi[UsersController, :show])
      b.method.should eq(:show)
      b.resource._id.should eq('users')

      b.apis.count.should == 1
      api = b.apis.first
      api.short_description.should eq("Show user profile")
      api.api_url.should eq("#{Restapi.configuration.api_base_url}/users/:id")
      api.http_method.should eq("GET")
      b.full_description.length.should be > 400
    end

    context "contain :see option" do

      context "the key is valid" do 
        it "should contain reference to another method" do
          api = Restapi[UsersController, :see_another]
          api.see.should eq('users#create')
          Restapi['users#see_another'].should eq(Restapi[UsersController, :see_another])
          api.see_url.should eq(Restapi[UsersController, :create].doc_url)
        end
      end

      context "the key is not valid" do
        it "should raise exception" do
          api = Restapi[UsersController, :see_another]
          api.instance_variable_set :@see, 'doesnot#exist'
          lambda {
            api.see_url
          }.should raise_error(ArgumentError, /does not exist/)
          api.instance_variable_set :@see, nil
        end
      end
    end

    it "should contain possible errors description" do
      a = Restapi.get_method_description(UsersController, :show)

      a.errors[0].code.should eq(401)
      a.errors[0].description.should eq("Unauthorized")
      a.errors[1].code.should eq(404)
      a.errors[1].description.should eq("Not Found")
    end

    it "should contain all params description" do
      a = Restapi.get_method_description(UsersController, :show)
      a.params.count.should == 8
      a.instance_variable_get('@params_ordered').count.should == 6
    end

    it "should contain all api method description" do
      method_description = Restapi[UsersController, :two_urls]
      method_description.class.should be(Restapi::MethodDescription)
      method_description.apis.count.should == 2
      a1, a2 = method_description.apis

      a1.short_description.should eq('Get company users')
      a1.api_url.should eq('/api/company_users')
      a1.http_method.should eq('GET')

      a2.short_description.should eq('Get users working in given company')
      a2.api_url.should eq('/api/company/:id/users')
      a2.http_method.should eq('GET')
    end

    it "should be described by valid json" do
      json = Restapi[UsersController, :two_urls].to_json
      expected_hash = {
        :errors => [],
        :examples => [],
        :doc_url => "#{Restapi.configuration.doc_base_url}/users/two_urls",
        :full_description => '',
        :params => [{:full_name=>"oauth",
                     :required=>false,
                     :allow_nil => false,
                     :validator=>"Parameter has to be String.",
                     :description=>"\n<p>Authorization</p>\n",
                     :name=>"oauth",
                     :expected_type=>"string"},
                    {:validator=>"Has to be hash.",
                     :description=>"\n<p>Param description for all methods</p>\n",
                     :expected_type=>"hash",
                     :allow_nil=>false,
                     :name=>"resource_param",
                     :required=>false,
                     :full_name=>"resource_param",
                     :params=>
                      [{:required=>true,
                        :allow_nil => false,
                        :validator=>"Parameter has to be String.",
                        :description=>"\n<p>Username for login</p>\n",
                        :name=>"ausername", :full_name=>"resource_param[ausername]",
                        :expected_type=>"string"},
                       {:required=>true,
                        :allow_nil => false,
                        :validator=>"Parameter has to be String.",
                        :description=>"\n<p>Password for login</p>\n",
                        :name=>"apassword", :full_name=>"resource_param[apassword]",
                        :expected_type=>"string"}
                      ]
                    },
                    {:required=>false, :validator=>"Parameter has to be Integer.",
                     :allow_nil => false,
                     :description=>"\n<p>Company ID</p>\n",
                     :name=>"id", :full_name=>"id",
                     :expected_type=>"numeric"},
       ],
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

      compare_hashes json, expected_hash
    end

  end

  describe "examples" do

    it "should be able to load examples from yml file" do
      Restapi.get_method_description(UsersController, :show).examples.should == [<<EOS1, <<EOS2].map(&:chomp)
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
  end

  describe "param description" do

    it "should contain all specified information" do
      a = Restapi.get_method_description(UsersController, :show)

      param = a.params[:session]
      param.required.should eq(true)
      param.desc.should eq("\n<p>user is logged in</p>\n")
      param.validator.class.should be(Restapi::Validator::TypeValidator)
      param.validator.instance_variable_get("@type").should eq(String)

      param = a.params[:id]
      param.required.should eq(true)
      param.desc.should eq("\n<p>user id</p>\n")
      param.validator.class.should be(Restapi::Validator::IntegerValidator)
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
    end

  end

end
