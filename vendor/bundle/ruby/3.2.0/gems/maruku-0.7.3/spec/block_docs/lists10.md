Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
List:

- è`gcc`

*** Output of inspect ***
md_el(:document,[
	md_par(["List:"]),
	md_el(:ul,[
		md_el(:li,["è", md_code("gcc")],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<p>List:</p>

<ul>
<li>è<code>gcc</code></li>
</ul>
*** Output of to_latex ***
List:

\begin{itemize}%
\item è{\colorbox[rgb]{1.00,0.93,1.00}{\tt gcc}}

\end{itemize}
*** Output of to_md ***
List:

- è`gcc`
*** Output of to_s ***
List:è
