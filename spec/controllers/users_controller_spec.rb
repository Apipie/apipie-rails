require 'spec_helper'

describe UsersController do

  describe "GET show" do

    it "find a user with id" do
      get :show, :id => 1, :version => 1
      
      # foo.id.should eq(1001
      assigns(:user)[:id].should eq(1)
      assert_response :success
    end

    it "throw ArgumentError if some required parameter missing" do
      lambda { get :show, :id => 1 }.should raise_error(ArgumentError)
    end

    it "is annotated" do
      
      a = Restapi.application.get_api(UsersController, :show)
      b = Restapi.application[UsersController, :show]
      a.should eq(b)

      a.method_name.should eq([UsersController, :show])
      a.errors.should eq([{:code=>444, :desc=>"random error"}])
      a.api_args.should eq({:desc=>"Show user profile", :path=>"/users/:id", :method=>"GET"})
      a.params.should eq({:id=>{:desc=>"user id", :required=>true, :validator=>Integer}, :version=>{:desc=>"user resource version", :required=>true, :validator=>Integer}})
      a.full_description.should eq("+Show user+ This is *description* of user show method.")
    end
  end

end
