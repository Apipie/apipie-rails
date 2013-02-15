require "spec_helper"

describe Apipie::ResourceDescription do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  describe "methods descriptions" do

    before(:each) do
      @resource = Apipie::ResourceDescription.new(ApplicationController, "dummy")
      a = Apipie::MethodDescription.new(:a, @resource, dsl_data)
      b = Apipie::MethodDescription.new(:b, @resource, dsl_data)
      c = Apipie::MethodDescription.new(:c, @resource, dsl_data)
      @resource.add_method_description(a)
      @resource.add_method_description(b)
      @resource.add_method_description(c)
    end

    it "should be ordered" do
      @resource._methods.keys.should == [:a, :b, :c]
      @resource.to_json[:methods].map{|h| h[:name]}.should == ['a', 'b', 'c']
    end

    it "should be still ordered" do
      @resource._methods.keys.should == [:a, :b, :c]
      @resource.to_json[:methods].map{|h| h[:name]}.should == ['a', 'b', 'c']
    end

  end
end
