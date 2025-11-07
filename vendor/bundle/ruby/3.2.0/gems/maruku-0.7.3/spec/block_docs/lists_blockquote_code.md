Lists should be able to contain blockquotes and code.
*** Parameters: ***
{}
*** Markdown input: ***
*   A list item with a blockquote:

    > This is a blockquote
    > inside a list item.

*   A list item with a code block:

        <code goes here>
*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[
		md_el(:li,[
			md_par(["A list item with a blockquote:"]),
			md_el(:quote,[md_par(["This is a blockquote inside a list item."])],{},[])
		],{:want_my_paragraph=>true},[]),
		md_el(:li,[
			md_par(["A list item with a code block:"]),
			md_el(:code,[],{:raw_code=>"<code goes here>", :lang=>nil},[])
		],{:want_my_paragraph=>true},[])
	],{},[])
],{},[])
*** Output of to_html ***
<ul>
<li>
<p>A list item with a blockquote:</p>

<blockquote>
<p>This is a blockquote inside a list item.</p>
</blockquote>
</li>

<li>
<p>A list item with a code block:</p>

<pre><code>&lt;code goes here&gt;</code></pre>
</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item A list item with a blockquote:

\begin{quote}%
This is a blockquote inside a list item.


\end{quote}

\item A list item with a code block:

\begin{verbatim}<code goes here>\end{verbatim}


\end{itemize}
*** Output of to_md ***
- list item with a blockquote:
This is a blockquote inside a list
item.
- list item with a code block:
*** Output of to_s ***
A list item with a blockquote:This is a blockquote inside a list item.A list item with a code block:
