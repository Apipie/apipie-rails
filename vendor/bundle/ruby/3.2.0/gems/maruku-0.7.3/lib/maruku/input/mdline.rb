# This code does the classification of lines for block-level parsing.
module MaRuKu

  # Represents a single line in a Markdown source file, as produced by
  # LineSource.
  class MDLine < String
    def md_type
      @md_type ||= line_md_type
    end

    # Returns the number of leading spaces on this string,
    # considering that a tab counts as {MaRuKu::Strings::TAB_SIZE} spaces.
    #
    # @param s [String]
    # @return [Fixnum]
    def number_of_leading_spaces
      if self =~ /\A\s+/
        spaces = $&
        spaces.count(" ") + spaces.count("\t") * MaRuKu::Strings::TAB_SIZE
      else
        0
      end
    end

    def gsub!(*args)
      # Any in-place-modification method should reset the md_type
      @md_type = nil
      super
    end

    private

    def line_md_type
      # The order of evaluation is important (:text is a catch-all)
      return :text           if self =~ /\A[a-zA-Z]/
      return :empty          if self =~ /\A\s*\z/
      return :footnote_text  if self =~ FootnoteText
      return :ref_definition if self =~ LinkRegex || self =~ IncompleteLink
      return :abbreviation   if self =~ Abbreviation
      return :definition     if self =~ Definition
      # I had a bug with emails and urls at the beginning of the
      # line that were mistaken for raw_html
      return :text           if self =~ /\A[ ]{0,3}#{EMailAddress}/
      return :text           if self =~ /\A[ ]{0,3}<\w+:\/\//
      # raw html is like PHP Markdown Extra: at most three spaces before
      return :xml_instr      if self =~ /\A\s*<\?/
      return :raw_html       if self =~ %r{\A[ ]{0,3}</?\s*\w+}
      return :raw_html       if self =~ /\A[ ]{0,3}<\!\-\-/
      return :header1        if self =~ /\A(=)+/
      return :header2        if self =~ /\A([-\s])+\z/
      return :header3        if self =~ /\A(#)+\s*\S+/
      # at least three asterisks/hyphens/underscores on a line, and only whitespace
      return :hrule          if self =~ /\A(\s*[\*\-_]\s*){3,}\z/
      return :ulist          if self =~ /\A[ ]{0,3}([\*\-\+])\s+.*/
      return :olist          if self =~ /\A[ ]{0,3}\d+\.\s+.*/
      return :code           if number_of_leading_spaces >= 4
      return :quote          if self =~ /\A>/
      return :ald            if self =~ AttributeDefinitionList
      return :ial            if self =~ InlineAttributeList
      return :text # else, it's just text
    end
  end

  # MacRuby has trouble with commented regexes, so just put the expanded form
  # in a comment.

  # $1 = id   $2 = attribute list
  AttributeDefinitionList = /\A\s{0,3}\{([\w\s]+)\}:\s*(.*?)\s*\z/
  #
  InlineAttributeList = /\A\s{0,3}\{([:#\.].*?)\}\s*\z/
  # Example:
  #     ^:blah blah
  #     ^: blah blah
  #     ^   : blah blah
  Definition = /\A[ ]{0,3}:\s*(\S.*)\z/
  # %r{
  #   ^ # begin of line
  #   [ ]{0,3} # up to 3 spaces
  #   : # colon
  #   \s* # whitespace
  #   (\S.*) # the text    = $1
  #   $ # end of line
  # }x

  # Example:
  #     *[HTML]: Hyper Text Markup Language
  Abbreviation = /\A[ ]{0,3}\*\[([^\]]+)\]:\s*(\S.*\S)*\s*\z/
  # %r{
  #   ^  # begin of line
  #   [ ]{0,3} # up to 3 spaces
  #   \* # one asterisk
  #   \[ # opening bracket
  #   ([^\]]+) # any non-closing bracket:  id = $1
  #   \] # closing bracket
  #   :  # colon
  #   \s* # whitespace
  #   (\S.*\S)* #           definition=$2
  #   \s* # strip this whitespace
  #   $   # end of line
  # }x

  FootnoteText = /\A[ ]{0,3}\[(\^.+)\]:\s*(\S.*)?\z/
  # %r{
  #   ^  # begin of line
  #   [ ]{0,3} # up to 3 spaces
  #   \[(\^.+)\]: # id = $1 (including '^')
  #   \s*(\S.*)?$    # text = $2 (not obb.)
  # }x

  # This regex is taken from BlueCloth sources
  # Link defs are in the form: ^[id]: \n? url "optional title"
  LinkRegex = /\A[ ]{0,3}\[([^\[\]]+)\]:[ ]*<?([^>\s]+)>?[ ]*(?:(?:(?:"([^"]+)")|(?:'([^']+)')|(?:\(([^\(\)]+)\)))\s*(.+)?)?/
  #%r{
  # ^[ ]{0,3}\[([^\[\]]+)\]:    # id = $1
  #   [ ]*
  # <?([^>\s]+)>?       # url = $2
  #   [ ]*
  # (?: # Titles are delimited by "quotes" or (parens).
  #   (?:(?:"([^"]+)")|(?:'([^']+)')|(?:\(([^\(\)]+)\))) # title = $3, $4, or $5
  #   \s*(.+)? # stuff = $6
  # )?  # title is optional
  #}x

  IncompleteLink = /\A[ ]{0,3}\[([^\[\]]+?)\]:\s*\z/

  # Table syntax: http://michelf.ca/projects/php-markdown/extra/#table
  # | -------------:| ------------------------------ |
  TableSeparator = /\A(?>\|?\s*\:?\-+\:?\s*\|?)+?\z/

  EMailAddress = /<([^:@>]+?@[^:@>]+?)>/
end
