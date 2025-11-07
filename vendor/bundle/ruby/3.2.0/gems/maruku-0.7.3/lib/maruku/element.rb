module MaRuKu
  # Rather than having a separate class for every possible element,
  # Maruku has a single {MDElement} class
  # that represents eveything in the document (paragraphs, headers, etc).
  # The type of each element is available via \{#node\_type}.
  class MDElement
    # The type of this node (e.g. `:quote`, `:image`, `:abbr`).
    # See {Helpers} for a list of possible values.
    #
    # @return [Symbol]
    attr_accessor :node_type

    # The child nodes of this element.
    #
    # @return [Array<String or MDElement>]
    attr_accessor :children

    # An attribute list. May not be nil.
    #
    # @return [AttributeList]
    attr_accessor :al

    # The processed attributes.
    #
    # For the {Maruku document root},
    # this contains properties listed
    # at the beginning of the document.
    # The properties will be downcased and any spaces
    # will be converted to underscores.
    # For example, if you write in the source document:
    #
    #     !!!text
    #     Title: test document
    #     My property: value
    #
    #     content content
    #
    # Then \{#attributes} will return:
    #
    #     {:title => "test document", :my_property => "value"}
    #
    # @return [{Symbol => String}]
    attr_accessor :attributes

    # The root element of the document
    # to which this element belongs.
    #
    # @return [Maruku]
    attr_accessor :doc

    def initialize(node_type = :unset, children = [], meta = {}, al = nil)
      self.children = children
      self.node_type = node_type
      self.attributes = {}

      # Define a new accessor on the singleton class for this instance
      # for each metadata key
      meta.each do |symbol, value|
        class << self
          self
        end.send(:attr_accessor, symbol)

        self.send("#{symbol}=", value)
      end

      self.al = al || AttributeList.new
      self.meta_priv = meta
    end

    # @private
    attr_accessor :meta_priv

    def ==(o)
      o.is_a?(MDElement) &&
        self.node_type == o.node_type &&
        self.meta_priv == o.meta_priv &&
        self.children == o.children
    end

    # Iterates through each {MDElement} child node of this element.
    # This includes deeply-nested child nodes.
    # If `e_node_type` is specified, only yields nodes of that type.
    def each_element(e_node_type=nil, &block)
      @children.each do |c|
        if c.is_a? MDElement then
          yield c if e_node_type.nil? || c.node_type == e_node_type
          c.each_element(e_node_type, &block)
        #
        # This handles the case where the children of an 
        # element are arranged in a multi-dimensional array 
        # (as in the case of a table)
        elsif c.is_a? Array then
          c.each do |cc|
            # A recursive call to each_element will ignore the current element
            # so we handle this case inline
            if cc.is_a? MDElement then
              yield cc if e_node_type.nil? || cc.node_type == e_node_type
              cc.each_element(e_node_type, &block)
            end
          end
        end

      end
    end

    # Iterates through each String child node of this element,
    # replacing it with the result of the block.
    # This includes deeply-nested child nodes.
    #
    # This destructively modifies this node and its children.
    #
    # @todo Make this non-destructive
    def replace_each_string(&block)
      @children.map! do |c|
        next yield c if c.is_a?(String)
        c.replace_each_string(&block)
        c
      end
      @children.flatten! unless self.node_type == :table
    end
  end

  # A specialization of Element that can keep track of
  # its parsed HTML as an attribute (rather than metadata)
  class MDHTMLElement < MDElement
    attr_accessor :parsed_html # HTMLFragment
  end
end

class Array
  def replace_each_string(&block)
    self.map! do |c|
      next yield c if c.is_a?(String)
      c.replace_each_string(&block)
      c
    end
  end
end
