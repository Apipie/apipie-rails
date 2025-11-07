require File.dirname(__FILE__) + '/../spec_helper'

describe "lite_mode_html" do
  examples_from_yaml do |doc|
    RedCloth.new(doc['in'], [:lite_mode]).to_html
  end
end