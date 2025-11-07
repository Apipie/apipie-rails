require File.dirname(__FILE__) + '/spec_helper'

describe RedCloth do
  
  describe "#new" do
    it "should accept options" do
      expect {
        RedCloth.new("test", [:hard_breaks])
      }.not_to raise_error
    end
  end
  
  it "should have a VERSION" do
    expect(RedCloth.const_defined?("VERSION")).to be_truthy
    expect(RedCloth::VERSION.const_defined?("STRING")).to be_truthy
  end
  
  it "should show the version as a string" do
    RedCloth::VERSION::STRING.should == RedCloth::VERSION.to_s
    RedCloth::VERSION.should == RedCloth::VERSION::STRING
  end
  
  it "should have EXTENSION_LANGUAGE" do
    RedCloth.const_defined?("EXTENSION_LANGUAGE").should be_truthy
    RedCloth::EXTENSION_LANGUAGE.should_not be_empty
    RedCloth::DESCRIPTION.should include(RedCloth::EXTENSION_LANGUAGE)
  end
  
  it "should not segfault on a badly formatted table" do
    RedCloth.new(%Q{| one | two |\nthree | four |}).to_html.should =~ /td/
  end
  
  it "should not segfault on a table without a block end" do
    RedCloth.new("| a | b |\n| c | d |\nh3. foo").to_html.should =~ /h3/
  end
  
  it "should not segfault on a table with empty cells" do
    RedCloth.new(%Q{|one || |\nthree | four |}).to_html.should =~ /td/
  end
  
  it "should not segfault on an unfinished html block with filter_html" do
    lambda { RedCloth.new(%Q{<hr> Some text}, [:filter_html]).to_html }.should_not raise_error
  end
  
  it "should parse RedCloth::VERSION in input" do
    RedCloth.new("RedCloth::VERSION").to_html.should == "<p>#{RedCloth::VERSION::STRING}</p>"
  end
  
  it "should not parse RedCloth::VERSION if it's not on a line by itself" do
    input = "RedCloth::VERSION won't output the RedCloth::VERSION unless it's on a line all by itself.\n\nRedCloth::VERSION"
    html = "<p>RedCloth::<span class=\"caps\">VERSION</span> won&#8217;t output the RedCloth::<span class=\"caps\">VERSION</span> unless it&#8217;s on a line all by itself.</p>\n<p>#{RedCloth::VERSION::STRING}</p>"
    RedCloth.new(input).to_html.should == html
  end
  
  it "should output the RedCloth::VERSION if it's labeled on a line by itself" do
    input = "RedCloth::VERSION: RedCloth::VERSION"
    html = "<p>RedCloth::VERSION: #{RedCloth::VERSION::STRING}</p>"
    RedCloth.new(input).to_html.should == html
  end
  
  it "should output the RedCloth::VERSION if it's labeled in a sentence on a line by itself" do
    input = "RedCloth version RedCloth::VERSION"
    html = "<p>RedCloth version #{RedCloth::VERSION::STRING}</p>"
    RedCloth.new(input).to_html.should == html
  end
  
  it "should output the RedCloth::VERSION in brackets" do
    input = "The current RedCloth version is [RedCloth::VERSION]"
    html = "<p>The current RedCloth version is #{RedCloth::VERSION::STRING}</p>"
    RedCloth.new(input).to_html.should == html
  end
  
  it "should strip carriage returns" do
    input = "This is a paragraph\r\n\r\nThis is a\r\nline break.\r\n\r\n<div>\r\ntest\r\n\r\n</div>"
    html = "<p>This is a paragraph</p>\n<p>This is a<br />\nline break.</p>\n<div>\n<p>test</p>\n</div>"
    RedCloth.new(input).to_html.should == html
  end

  it "should not add spurious li tags to the end of markup" do
    input         = "* one\n* two\n* three \n\n"
    failing_input = "* one\n* two\n* three \n\n\n"
    RedCloth.new(input).to_html.should_not match(/<li>$/)
    RedCloth.new(failing_input).to_html.should_not match(/<li>$/)
  end
  
  if RUBY_VERSION > "1.9.0"
    it "should preserve character encoding" do
      input = "This is an ISO-8859-1 string".dup
      input.force_encoding 'iso-8859-1'

      output = RedCloth.new(input).to_html
      
      output.should == "<p>This is an <span class=\"caps\">ISO</span>-8859-1 string</p>"
      output.encoding.to_s.should == "ISO-8859-1"
    end
    
    it "should not raise ArgumentError: invalid byte sequence" do
      s = "\xa3".dup
      s.force_encoding 'iso-8859-1'
      lambda { RedCloth.new(s).to_html }.should_not raise_error
    end
  end
end
