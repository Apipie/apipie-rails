require "spec_helper"

describe Apipie::Extractor::Writer do

  let(:collector) { double "collector" }
  let(:writer_class) { Apipie::Extractor::Writer }
  let(:writer) { writer_class.new(collector) }
  let(:test_examples_file) { File.join(Rails.root, "doc", "apipie_examples_test.json") }
  let(:records) { {
    "concern_resources#show" =>
      [{
        :controller=>ConcernsController,
        :action=>"show",
        :verb=>:GET,
        :path=>"/api/concerns/5",
        :params=>{},
        :query=>"session=secret_hash",
        :request_data=>nil,
        :response_data=>"OK {\"session\"=>\"secret_hash\", \"id\"=>\"5\", \"controller\"=>\"concerns\", \"action\"=>\"show\"}",
        :code=>"200"
      }, {
        :controller=>ConcernsController,
        :action=>"show",
        :verb=>:GET,
        :path=>"/api/concerns/5",
        :params=>{},
        :query=>"",
        :request_data=>nil,
        :response_data=>"OK {\"id\"=>\"5\", \"controller\"=>\"concerns\", \"action\"=>\"show\"}",
        :code=>"200"
      }]
    }
  }
  let(:loaded_records) { {
    "concern_resources#show" =>
      [{
        "verb"=>:GET,
        "path"=>"/api/concerns/5",
        "versions"=>["development"],
        "query"=>"session=secret_hash",
        "request_data"=>nil,
        "response_data"=>"OK {\"session\"=>\"secret_hash\", \"id\"=>\"5\", \"controller\"=>\"concerns\", \"action\"=>\"show\"}",
        "code"=>"200",
        "show_in_doc"=>1,
        "recorded"=>true
      }, {
        "verb"=>:GET,
        "path"=>"/api/concerns/5",
        "versions"=>["development"],
        "query"=>"",
        "request_data"=>nil,
        "response_data"=>"OK {\"id\"=>\"5\", \"controller\"=>\"concerns\", \"action\"=>\"show\"}",
        "code"=>"200",
        "show_in_doc"=>0,
        "recorded"=>true
      }]
    }
  }

  describe "with doc_path overriden in configuration" do
    it "should use the doc_path specified in configuration" do
      Apipie.configuration.doc_path = "user_specified_doc_path"
      expect(writer_class.examples_file).to eql(File.join(Rails.root, "user_specified_doc_path", "apipie_examples.json"))
    end
  end

  describe "storing of examples" do
    before do
      allow(writer_class).to receive(:examples_file) { test_examples_file }
      expect(collector).to receive(:records).and_return(records)
    end

    it "should read and write examples" do
      writer.write_examples
      expect(writer.send(:load_recorded_examples)).to eql(loaded_records)
    end

    after do
      File.unlink(test_examples_file) if File.exists?(test_examples_file)
    end
  end
end
