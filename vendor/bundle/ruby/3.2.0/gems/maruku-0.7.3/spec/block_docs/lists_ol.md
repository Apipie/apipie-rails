Maruku should handle weirdly indented lists.
*** Parameters: ***
{}
*** Markdown input: ***
1.   Lorem ipsum dolor sit amet, consectetuer adipiscing elit.
    Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi,
    viverra nec, fringilla in, laoreet vitae, risus.
 2.   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
    Suspendisse id sem consectetuer libero luctus adipiscing.
3.   Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
 3.  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
Suspendisse id sem consectetuer libero luctus adipiscing.
 4.  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
 Suspendisse id sem consectetuer libero luctus adipiscing.

Ancora

 1.  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
 Suspendisse id sem consectetuer libero luctus adipiscing.

         This is code

2.  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
 Suspendisse id sem consectetuer libero luctus adipiscing.

        This is code
3.  Donec sit amet nisl. Aliquam semper ipsum sit amet velit.
 Suspendisse id sem consectetuer libero luctus adipiscing.

       This is not code

*** Output of inspect ***
md_el(:document,[
	md_el(:ol,[
		md_li([
			"Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus."
		],false),
		md_li([
			"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],false),
		md_li([
			"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],false),
		md_li([
			"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],false),
		md_li([
		"Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."
		],false)
	],{},[]),
	md_par(["Ancora"]),
	md_el(:ol,[
		md_li([
			md_par("Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."),
			md_el(:code, [], {:raw_code=>"This is code", :lang=>nil})
		],true),
		md_li([
			md_par("Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."),
			md_el(:code, [], {:raw_code=>"This is code", :lang=>nil})
		],true),
		md_li([
			md_par("Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing."),
			md_par("This is not code")
		],nil),
	],{},[]),
],{},[])
*** Output of to_html ***
<ol>
<li>Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>

<li>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</li>
</ol>

<p>Ancora</p>

<ol>
<li>

<p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</p>

<pre><code>This is code</code></pre>
</li>
<li>

<p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</p>

<pre><code>This is code</code></pre>
</li>
<li>

<p>Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.</p>

<p>This is not code</p>
</li>
</ol>
*** Output of to_latex ***
\begin{enumerate}%
\item Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.

\end{enumerate}
Ancora

\begin{enumerate}%
\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.

\begin{verbatim}This is code\end{verbatim}

\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.

\begin{verbatim}This is code\end{verbatim}

\item Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.

This is not code



\end{enumerate}