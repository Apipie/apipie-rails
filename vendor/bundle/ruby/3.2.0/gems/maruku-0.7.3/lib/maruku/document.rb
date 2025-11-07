module MaRuKu
  # This represents the whole document and holds global data.
  class MDDocument # < MDElement
    # @return [{String => {:url => String, :title => String}}]
    attr_accessor :refs

    # @return [{String => MDElement}]
    attr_accessor :footnotes

    # @return [{String => String}]
    attr_accessor :abbreviations

    # Attribute definition lists.
    #
    # @return [{String => AttributeList}]
    attr_accessor :ald

    # The order in which footnotes are used. Contains the id.
    #
    # @return [Array<String>]
    attr_accessor :footnotes_order

    # @return [{String => {String => MDElement}}]
    attr_accessor :refid2ref

    # A counter for generating unique IDs [Integer]
    attr_accessor :id_counter

    def initialize(s=nil)
      super(:document)

      self.doc = self
      self.refs = {}
      self.footnotes = {}
      self.footnotes_order = []
      self.abbreviations = {}
      self.ald = {}
      self.refid2ref = {}
      self.id_counter = 0

      parse_doc(s) if s
    end
  end
end
