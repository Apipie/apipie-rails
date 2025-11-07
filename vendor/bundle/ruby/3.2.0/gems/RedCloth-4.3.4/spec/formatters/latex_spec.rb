require File.dirname(__FILE__) + '/../spec_helper'

describe "LaTeX" do
  examples_from_yaml do |doc|
    RedCloth.new(doc['in']).to_latex
  end
  
  it "should not raise an error when orphaned parentheses in a link are followed by punctuation and words in LaTeX" do
    expect { 
      RedCloth.new(%Q{Test "(read this":http://test.host), ok}).to_latex
    }.not_to raise_error
  end
end