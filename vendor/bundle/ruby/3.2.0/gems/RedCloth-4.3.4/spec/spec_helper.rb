$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])
require 'redcloth'
require 'yaml'
  
def examples_from_yaml(&block)
  formatter = description.downcase
  define_method("format_as_#{formatter}", &block)
  
  fixtures.each do |name, doc|
    if doc[formatter]
      example("should output #{formatter} for #{name}") do
        output = method("format_as_#{formatter}").call(doc)
        expect(output).to eq(doc[formatter])
      end
    else
      example("should not raise errors when rendering #{formatter} for #{name}") do
        expect { method("format_as_#{formatter}").call(doc) }.not_to raise_error
      end
    end
  end
end

def fixtures
  return @fixtures if @fixtures
  @fixtures = {}
  Dir[File.join(File.dirname(__FILE__), *%w[fixtures *.yml])].each do |testfile|
    testgroup = File.basename(testfile, '.yml')
    num = 0
    YAML::load_stream(File.open(testfile)) do |doc|
      name = doc['name'] || num
      @fixtures["#{testgroup} #{name}"] = doc
      num += 1
    end
  end
  @fixtures
end
