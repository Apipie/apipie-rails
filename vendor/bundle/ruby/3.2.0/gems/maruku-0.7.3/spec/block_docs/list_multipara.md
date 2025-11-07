Lists with multiple paragraphs
*** Parameters: ***
{}
*** Markdown input: ***
*   A list item with a couple paragraphs,
    each of which is indented.
    
    For example, this paragraph.

*   Another list item
*** Output of inspect ***
md_el(:document, md_el(:ul, [
	md_li([
	  md_par("A list item with a couple paragraphs, each of which is indented."),
	  md_par("For example, this paragraph.")
  ], true),
	md_li(md_par("Another list item"), false)
]))
*** Output of to_html ***
<ul>
<li>
<p>A list item with a couple paragraphs, each of which is indented.</p>

<p>For example, this paragraph.</p>
</li>

<li>
<p>Another list item</p>
</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item A list item with a couple paragraphs, each of which is indented.

For example, this paragraph.


\item Another list item



\end{itemize}
