require "spec_helper"

describe Apipie::ResourceDescription do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  describe "metadata" do

    it "should return nil when no metadata is provided" do
      resource = Apipie::ResourceDescription.new(ApplicationController, "dummy", dsl_data)
      expect(resource.to_json[:metadata]).to eq(nil)
    end

    it "should return the metadata" do
      meta = {
        :lenght => 32,
        :weight => '830g'
      }
      resource = Apipie::ResourceDescription.new(ApplicationController, "dummy", dsl_data.update(:meta => meta))
      expect(resource.to_json[:metadata]).to eq(meta)
    end

  end

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
      expect(@resource._methods.keys).to eq([:a, :b, :c])
      expect(@resource.to_json[:methods].map{|h| h[:name]}).to eq(['a', 'b', 'c'])
    end

    it "should be still ordered" do
      expect(@resource._methods.keys).to eq([:a, :b, :c])
      expect(@resource.to_json[:methods].map{|h| h[:name]}).to eq(['a', 'b', 'c'])
    end

  end
end
