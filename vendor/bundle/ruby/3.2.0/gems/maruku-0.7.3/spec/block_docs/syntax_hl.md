Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
This is ruby code:

	require 'maruku'
	
	puts Maruku.new($stdin).to_html

This is ruby code:

	require 'maruku'
{: lang=ruby html_use_syntax}
	
	puts Maruku.new($stdin).to_html
*** Output of inspect ***
md_el(:document,[
	md_par(["This is ruby code:"]),
	md_el(:code,[],{:raw_code=>"require 'maruku'\n\nputs Maruku.new($stdin).to_html", :lang=>nil},[]),
	md_par(["This is ruby code:"]),
	md_el(:code,[],{:raw_code=>"require 'maruku'", :lang=>nil},[["lang", "ruby"], [:ref, "html_use_syntax"]]),
	md_el(:code,[],{:raw_code=>"puts Maruku.new($stdin).to_html", :lang=>nil},[])
],{},[])
*** Output of to_html ***
<p>This is ruby code:</p>

<pre><code>require 'maruku'

puts Maruku.new($stdin).to_html</code></pre>

<p>This is ruby code:</p>

<pre class="ruby"><code class="ruby"><span class="ident">require</span> <span class="punct">'</span><span class="string">maruku</span><span class="punct">'</span></code></pre>

<pre><code>puts Maruku.new($stdin).to_html</code></pre>
*** Output of to_latex ***
This is ruby code:

\begin{verbatim}require 'maruku'

puts Maruku.new($stdin).to_html\end{verbatim}
This is ruby code:

\begin{verbatim}require 'maruku'\end{verbatim}
\begin{verbatim}puts Maruku.new($stdin).to_html\end{verbatim}
*** Output of to_md ***
This is ruby code:

     require 'maruku'
     
     puts Maruku.new($stdin).to_html

This is ruby code:

     require 'maruku'

     puts Maruku.new($stdin).to_html
*** Output of to_s ***
This is ruby code:This is ruby code:
