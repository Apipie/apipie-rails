require "spec_helper"

describe Apipie::ResourceDescription do

  describe "methods descriptions" do

    before(:each) do
      @resource = Apipie::ResourceDescription.new(ApplicationController, "dummy")
      a = Apipie::MethodDescription.new(:a, @resource, Apipie.app)
      b = Apipie::MethodDescription.new(:b, @resource, Apipie.app)
      c = Apipie::MethodDescription.new(:c, @resource, Apipie.app)
      @resource.add_method_description a
      @resource.add_method_description b
      @resource.add_method_description c
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