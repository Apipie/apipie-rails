# encoding: UTF-8

require File.dirname(__FILE__) + '/spec_helper'
require 'rspec'
require 'maruku'

describe "Maruku to_html" do
  # This test used to hang in JRuby!
  it "can produce HTML for a document that contains non-ASCII characters" do
    doc = Maruku.new.instance_eval 'md_el(:document,["è"],{},[])'
    doc.to_html.strip.should == "è"
  end
end
