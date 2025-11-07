Lists should allow newlines between items.
*** Parameters: ***
{}
*** Markdown input: ***
*   A list item



*   Another list item
*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[
    md_li(md_par("A list item"), true),
    md_li(md_par("Another list item"), false)
	])
])
*** Output of to_html ***
<ul>
<li>
<p>A list item</p>
</li>
<li>
<p>Another list item</p>
</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item A list item


\item Another list item



\end{itemize}
