require 'yaml' 

module RedCloth::Formatters::LATEX
  include RedCloth::Formatters::Base

  def self.entities
    @entities ||= YAML.load(File.read(File.dirname(__FILE__)+'/latex_entities.yml'))
  end

  module Settings
    # Maps CSS style names to latex formatting options
    def latex_image_styles
      @latex_image_class_styles ||= {}
    end
  end

  RedCloth::TextileDoc.send(:include, Settings)

  # headers
  { :h1 => 'section',
    :h2 => 'subsection',
    :h3 => 'subsubsection',
    :h4 => 'paragraph',
    :h5 => 'subparagraph',
    :h6 => 'textbf',
  }.each do |m,tag| 
    define_method(m) do |opts| 
      case opts[:align]
      when 'left' then
        "\\begin{flushleft}\\#{tag}{#{opts[:text]}}\\end{flushleft}\n\n" 
      when 'right' then
        "\\begin{flushright}\\#{tag}{#{opts[:text]}}\\end{flushright}\n\n" 
      when 'center' then
        "\\begin{center}\\#{tag}{#{opts[:text]}}\\end{center}\n\n" 
      else
        "\\#{tag}{#{opts[:text]}}\n\n"
      end
    end 
  end 

  # commands 
  { :strong => 'textbf',
    :em => 'emph',
    :i  => 'textit',
    :b  => 'textbf',
    :ins => 'underline',
    :del => 'sout',
  }.each do |m,tag|
    define_method(m) do |opts|
      "\\#{tag}{#{opts[:text]}}"
    end
  end

  # inline code
  def code(opts)
    opts[:block] ? opts[:text] : "\\verb@#{opts[:text]}@"
  end

  # acronyms
  def acronym(opts)
    "#{opts[:title]} (#{opts[:text]})"
  end

  # sub/superscripts
  { :sup => '\textsuperscript{#1}',
    :sub => '\textsubscript{#1}',
  }.each do |m, expr|
    define_method(m) do |opts|
      expr.sub('#1', opts[:text])
    end
  end

  # environments
  { :pre  => 'verbatim',
    :cite => 'quote',
    }.each do |m, env|
    define_method(m) do |opts|
      begin_chunk(env) + opts[:text] + end_chunk(env)
    end
  end

  # ignore (or find a good solution later)
  [ :span,
    :div,
    :caps
    ].each do |m|
    define_method(m) do |opts|
      opts[:text].to_s
    end
  end

  # lists
  { :ol => 'enumerate',
    :ul => 'itemize',
    }.each do |m, env|
    define_method("#{m}_open") do |opts|
      opts[:block] = true
      "\\begin{#{env}}\n"
    end
    define_method("#{m}_close") do |opts|
      "\\end{#{env}}\n\n"
    end
  end

  def li_open(opts)
    "  \\item #{opts[:text]}"
  end

  def li_close(opts=nil)
    "\n"
  end

  # paragraphs
  def p(opts)
    case opts[:align]
    when 'left' then
      "\\begin{flushleft}#{opts[:text]}\\end{flushleft}\n\n" 
    when 'right' then
      "\\begin{flushright}#{opts[:text]}\\end{flushright}\n\n" 
    when 'center' then
      "\\begin{center}#{opts[:text]}\\end{center}\n\n" 
    else
      "#{opts[:text]}\n\n"
    end
  end

  # tables
  def td(opts)
    column = @table_row.size
    if opts[:colspan]
      opts[:text] = "\\multicolumn{#{opts[:colspan]}}{ #{"l " * opts[:colspan].to_i}}{#{opts[:text]}}"
    end
    if opts[:rowspan]
      @table_multirow_next[column] = opts[:rowspan].to_i - 1
      opts[:text] = "\\multirow{#{opts[:rowspan]}}{*}{#{opts[:text]}}"
    end
    @table_row.push(opts[:text])
    return ""
  end

  def tr_open(opts)
    @table_row = []
    return ""
  end

  def tr_close(opts)
    multirow_columns = @table_multirow.find_all {|c,n| n > 0}
    multirow_columns.each do |c,n|
      @table_row.insert(c,"")
      @table_multirow[c] -= 1
    end
    @table_multirow.merge!(@table_multirow_next)
    @table_multirow_next = {}
    @table.push(@table_row)
    return ""
  end

  # We need to know the column count before opening tabular context.
  def table_open(opts)
    @table = []
    @table_multirow = {}
    @table_multirow_next = {}
    return ""
  end

  # FIXME: need caption and label elements similar to image -> figure
  def table_close(opts)
    output  = "\\begin{table}\n".dup
    output << "  \\centering\n"
    output << "  \\begin{tabular}{ #{"l " * @table[0].size }}\n"
    @table.each do |row|
      output << "    #{row.join(" & ")} \\\\\n"
    end
    output << "  \\end{tabular}\n"
    output << "\\end{table}\n"
    output
  end

  # code blocks
  def bc_open(opts)
    opts[:block] = true
    begin_chunk("verbatim") + "\n"
  end

  def bc_close(opts)
    end_chunk("verbatim") + "\n"
  end

  # block quotations
  def bq_open(opts)
    opts[:block] = true
    "\\begin{quotation}\n"
  end

  def bq_close(opts)
    "\\end{quotation}\n\n"
  end

  # links
  def link(opts)
    "\\href{#{opts[:href]}}{#{opts[:name]}}"
  end
  
  # FIXME: use includegraphics with security verification
  #
  # Remember to use '\RequirePackage{graphicx}' in your LaTeX header
  # 
  # FIXME: Look at dealing with width / height gracefully as this should be 
  # specified in a unit like cm rather than px.
  def image(opts)
    # Don't know how to use remote links, plus can we trust them?
    return "" if opts[:src] =~ /^\w+\:\/\//
    # Resolve CSS styles if any have been set
    styling = opts[:class].to_s.split(/\s+/).collect { |style| latex_image_styles[style] }.compact.join ','
    # Build latex code
    [ "\\begin{figure}",
      "  \\centering",
      "  \\includegraphics[#{styling}]{#{opts[:src]}}",
     ("  \\caption{#{escape opts[:title]}}" if opts[:title]),
     ("  \\label{#{escape opts[:alt]}}" if opts[:alt]),
      "\\end{figure}",
    ].compact.join "\n"
  end

  # footnotes
  def footno(opts)
    # TODO: insert a placeholder until we know the footnote content.
    # For this to work, we need some kind of post-processing...
    "\\footnotemark[#{opts[:text]}]"
  end

  def fn(opts)
    "\\footnotetext[#{opts[:id]}]{#{opts[:text]}}"
  end

  # inline verbatim
  def snip(opts)
    "\\verb`#{opts[:text]}`"
  end

  def quote1(opts)
    "`#{opts[:text]}'"
  end

  def quote2(opts)
    "``#{opts[:text]}''"
  end

  def ellipsis(opts)
    "#{opts[:text]}\\ldots{}"
  end

  def emdash(opts)
    "---"
  end

  def endash(opts)
    " -- "
  end

  def arrow(opts)
    "\\rightarrow{}"
  end

  def trademark(opts)
    "\\texttrademark{}"
  end

  def registered(opts)
    "\\textregistered{}"
  end

  def copyright(opts)
    "\\copyright{}"
  end

  # TODO: what do we do with (unknown) unicode entities ? 
  #
  def entity(opts)
    text = opts[:text][0..0] == '#' ? opts[:text][1..-1] : opts[:text]
    RedCloth::Formatters::LATEX.entities[text]
  end

  def dim(opts)
    opts[:text].gsub!('x', '\times')
    opts[:text].gsub!('"', "''")
    period = opts[:text].slice!(/\.$/)
    "$#{opts[:text]}$#{period}"
  end
  
  # TODO: what do we do with HTML?
  def inline_html(opts)
    opts[:text] || ""
  end
  
  private

  def escape(text)
    latex_esc(text)
  end

  def escape_pre(text)
    text
  end

  # Use this for block level commands that use \begin
  def begin_chunk(type)
    chunk_counter[type] += 1
    return "\\begin{#{type}}" if 1 == chunk_counter[type]
    ''
  end

  # Use this for block level commands that use \end
  def end_chunk(type)
    chunk_counter[type] -= 1
    raise RuntimeError, "Bad latex #{type} nesting detected" if chunk_counter[type] < 0 # This should never need to happen
    return "\\end{#{type}}" if 0 == chunk_counter[type]
    ''
  end

  def chunk_counter
    @chunk_counter ||= Hash.new 0
  end
end
