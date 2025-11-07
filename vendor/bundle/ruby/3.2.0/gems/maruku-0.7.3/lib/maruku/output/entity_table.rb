require 'rexml/document'
require 'singleton'

module MaRuKu::Out
  Entity = Struct.new(:html_num, :html_entity, :latex_string, :latex_package)

  class EntityTable
    # Sad but true
    include Singleton

    def initialize
      @entity_table = {}

      xml = File.new(File.join(File.dirname(__FILE__), '..', '..', '..', 'data', 'entities.xml'))
      doc = REXML::Document.new(xml)
      doc.elements.each("//char") do |c|
        num = c.attributes['num'].to_i
        name = c.attributes['name']
        convert = c.attributes['convertTo']
        package = c.attributes['package']

        e = Entity.new(num, name, convert, package)
        @entity_table[name] = e
        @entity_table[num] = e
      end
    end

    def entity(name)
      @entity_table[name]
    end

    def each
      @entity_table.each
    end
  end
end

