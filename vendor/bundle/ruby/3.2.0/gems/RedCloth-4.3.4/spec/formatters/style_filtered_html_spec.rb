require File.dirname(__FILE__) + '/../spec_helper'

describe "style_filtered_html" do
  examples_from_yaml do |doc|
    RedCloth.new(doc['in'], [:filter_styles]).to_html
  end
end