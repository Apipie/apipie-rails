# encoding: UTF-8
Encoding.default_external=('UTF-8') if ''.respond_to?(:force_encoding)

require File.dirname(__FILE__) + '/spec_helper'
require 'rspec'
require 'maruku'
require 'nokogiri/diff'

# Allow us to test both HTML parser backends
MaRuKu::Globals[:html_parser] = ENV['HTML_PARSER'] if ENV['HTML_PARSER']

puts "Using HTML parser: #{MaRuKu::Globals[:html_parser]}"

# :to_md and :to_s tests are disabled for now
METHODS = [:to_html, :to_latex]

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    }
  end
  return nil
end

if which('blahtex')
  HAS_BLAHTEX = true
else
  HAS_BLAHTEX = false
  puts "Install 'blahtex' to run blahtex math tests"
end

describe "A Maruku doc" do
  before(:all) do
    @old_stderr = $stderr
    $stderr = StringIO.new
  end

  after(:all) do
    $stderr = @old_stderr
  end

  Dir[File.dirname(__FILE__) + "/block_docs/**/*.md"].each do |md|
    next if md =~ /blahtex/ && !HAS_BLAHTEX

    md_pretty = md.sub(File.dirname(__FILE__) + '/', '')

    describe "#{md_pretty} (using #{MaRuKu::Globals[:html_parser]})" do
      input = File.read(md).split(/\n\*{3}[^*\n]+\*{3}\n/m)
      input = ["Write a comment here", "{}", input.first] if input.size == 1
      comment = input.shift.strip
      params = input.shift || ''
      markdown = input.shift || ''
      ast = input.shift || ''
      expected = METHODS.zip(input).inject({}) {|h, (k, v)| h[k] = v ? v.strip : '' ; h}

      pending "#{comment} - #{md_pretty}" and next if comment.start_with?("PENDING")
      pending "#{comment} - #{md_pretty}" and next if comment.start_with?("REXML PENDING") && MaRuKu::Globals[:html_parser] == 'rexml'
      pending "#{comment} - #{md_pretty}" and next if comment.start_with?("JRUBY PENDING") && RUBY_PLATFORM == 'java'
      pending "#{comment} - #{md_pretty}" and next if comment.start_with?("JRUBY NOKOGIRI PENDING") && RUBY_PLATFORM == 'java' && MaRuKu::Globals[:html_parser] == 'nokogiri'

      before(:each) do
        $already_warned_itex2mml = false
        @doc = Maruku.new(markdown, eval(params))
      end

      it "should read in the output of #inspect as the same document" do
        Maruku.new.instance_eval("#coding: utf-8\n#{@doc.inspect}", md).should == @doc
      end

      unless ast.strip.empty?
        it "should produce the given AST" do
          @doc.should == Maruku.new.instance_eval(ast, md)
        end
      end

      unless expected[:to_html].strip.empty?
        it "should have the expected to_html output" do
          res = @doc.to_html.strip
          pending "install itex2mml to run these tests" if $already_warned_itex2mml

          resdoc = Nokogiri::XML("<dummy>#{res}</dummy>")
          expdoc = Nokogiri::XML("<dummy>#{expected[:to_html]}</dummy>")

          diff = ""
          changed = false
          expdoc.diff(resdoc) do |change, node|
            diff << "#{change} #{node.inspect}\n"
            changed = true unless change == ' ' || (node.text? && node.content =~ /\A\s*\Z/m)
          end

          if changed
            res.should == expected[:to_html]
          end
        end
      end

      unless expected[:to_latex].strip.empty?
        it "should have the expected to_latex output" do
          res = @doc.to_latex.strip
          res.should == expected[:to_latex]
        end
      end
    end
  end


end
