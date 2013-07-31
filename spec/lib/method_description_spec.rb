require "spec_helper"

describe Apipie::MethodDescription do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  describe "params descriptions" do

    before(:each) do
      @resource = Apipie::ResourceDescription.new(ApplicationController, "dummy")
      dsl_data[:params] = [[:a, String, nil, {}, nil],
                           [:b, String, nil, {}, nil],
                           [:c, String, nil, {}, nil]]
      @method = Apipie::MethodDescription.new(:a, @resource, dsl_data)
      @resource.add_method_description @method
    end

    it "should be ordered" do
      @method.params.keys.should == [:a, :b, :c]
      @method.to_json[:params].map{|h| h[:name]}.should == ['a', 'b', 'c']
    end

    it "should be still ordered" do
      @method.params.keys.should == [:a, :b, :c]
      @method.to_json[:params].map{|h| h[:name]}.should == ['a', 'b', 'c']
    end

  end

end
