require File.dirname(__FILE__) + '/../spec_helper'

describe "class_filtered_html" do
  examples_from_yaml do |doc|
    RedCloth.new(doc['in'], [:filter_classes]).to_html
  end
end