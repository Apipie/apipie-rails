require "spec_helper"

describe Apipie::MethodDescription do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  describe "metadata" do

    before(:each) do
      @resource = Apipie::ResourceDescription.new(ApplicationController, "dummy")
    end

    it "should return nil when no metadata is provided" do
      method = Apipie::MethodDescription.new(:a, @resource, dsl_data)
      expect(method.to_json[:metadata]).to eq(nil)
    end

    it "should return the metadata" do
      meta = {
        :lenght => 32,
        :weight => '830g'
      }
      method = Apipie::MethodDescription.new(:a, @resource, dsl_data.update(:meta => meta))
      expect(method.to_json[:metadata]).to eq(meta)
    end

  end

  describe "deprecated flag" do
    before(:each) do
      @resource = Apipie::ResourceDescription.new(ApplicationController, "dummy")
    end

    it "should return the deprecated flag when provided" do
      dsl_data[:api_args] = [[:GET, "/foo/bar", "description", {:deprecated => true}]]
      method = Apipie::MethodDescription.new(:a, @resource, dsl_data)
      expect(method.method_apis_to_json.first[:deprecated]).to eq(true)
    end
  end

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
      expect(@method.params.keys).to eq([:a, :b, :c])
      expect(@method.to_json[:params].map{|h| h[:name]}).to eq(['a', 'b', 'c'])
    end

    it "should be still ordered" do
      expect(@method.params.keys).to eq([:a, :b, :c])
      expect(@method.to_json[:params].map{|h| h[:name]}).to eq(['a', 'b', 'c'])
    end

  end

end
