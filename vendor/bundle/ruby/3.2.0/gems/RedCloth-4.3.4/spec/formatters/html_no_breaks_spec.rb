require File.dirname(__FILE__) + '/../spec_helper'

describe "html_no_breaks" do
  examples_from_yaml do |doc|
    red = RedCloth.new(doc['in'])
    red.hard_breaks = false
    red.to_html
  end
end