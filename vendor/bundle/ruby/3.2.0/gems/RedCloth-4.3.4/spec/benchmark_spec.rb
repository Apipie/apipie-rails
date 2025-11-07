require File.dirname(__FILE__) + '/spec_helper'

describe "Benchmarking", :type => :formatter do
  version = RedCloth::VERSION.is_a?(Module) ? RedCloth::VERSION::STRING : RedCloth::VERSION
  platform = RedCloth.const_defined?(:EXTENSION_LANGUAGE) ? RedCloth::EXTENSION_LANGUAGE : (version < "4.0.0" ? "ruby-regex" : "C")
  
  it "should not be too slow" do
    # puts "Benchmarking version #{version} compiled in #{platform}..."
    fixtures.each do |name, doc|
      if doc['html']
        RedCloth.new(doc['in']).to_html
      end
    end
  end
end