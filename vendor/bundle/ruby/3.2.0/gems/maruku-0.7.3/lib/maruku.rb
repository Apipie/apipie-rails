#--
# Copyright (c) 2006 Andrea Censi
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module MaRuKu
  module In
    module Markdown
      module SpanLevelParser; end
      module BlockLevelParser; end
    end
  end

  module Out
    module Markdown; end
    module HTML; end
    module Latex; end
  end

  module Strings; end

  module Helpers; end

  module Errors; end

  class MDElement
    include MaRuKu
    include Out::Markdown
    include Out::HTML
    include Out::Latex
    include Strings
    include Helpers
    include Errors
  end

  class MDDocument < MDElement
    include In::Markdown
    include In::Markdown::SpanLevelParser
    include In::Markdown::BlockLevelParser
  end
end

class Maruku < MaRuKu::MDDocument; end


# Structures definition
require 'maruku/attributes'
require 'maruku/element'
require 'maruku/document'
require 'maruku/inspect_element'

require 'maruku/defaults'

# Less typing
require 'maruku/helpers'

# Code for parsing whole Markdown documents
require 'maruku/input/parse_doc'

# Ugly things kept in a closet
require 'maruku/string_utils'
require 'maruku/input/linesource'
require 'maruku/input/mdline'

# A class for reading and sanitizing inline HTML
require 'maruku/input/html_helper'

# Code for parsing Markdown block-level elements
require 'maruku/input/parse_block'

# Code for parsing Markdown span-level elements
require 'maruku/input/charsource'
require 'maruku/input/parse_span'

require 'maruku/input/extensions'

require 'maruku/errors'

# Code for creating a table of contents
require 'maruku/toc'

# Support for div Markdown extension
require 'maruku/ext/div'
# Support for fenced codeblocks extension
require 'maruku/ext/fenced_code'

# Version and URL
require 'maruku/version'

# Entity conversion for HTML and LaTeX
require 'maruku/output/entity_table'

# Exporting to html
require 'maruku/output/to_html'

# Exporting to latex
require 'maruku/output/to_latex'

# Pretty print
require 'maruku/output/to_markdown'

# S5 slides
require 'maruku/output/s5/to_s5'
require 'maruku/output/s5/fancy'

# Exporting to text: strips all formatting (not complete)
require 'maruku/output/to_s'

# class Maruku is the global interface
require 'maruku/maruku'
