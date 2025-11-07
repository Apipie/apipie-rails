require File.dirname(__FILE__) + '/../spec_helper'

describe "id_filtered_html" do
  examples_from_yaml do |doc|
    RedCloth.new(doc['in'], [:filter_ids]).to_html
  end
end