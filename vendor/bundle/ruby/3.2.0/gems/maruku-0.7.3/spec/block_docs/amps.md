Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
	@articles.map(&:title)
*** Output of inspect ***
md_el(:document,[md_el(:code,[],{:raw_code=>"@articles.map(&:title)", :lang=>nil},[])],{},[])
*** Output of to_html ***
<pre><code>@articles.map(&amp;:title)</code></pre>
*** Output of to_latex ***
\begin{verbatim}@articles.map(&:title)\end{verbatim}
*** Output of to_md ***

*** Output of to_s ***

