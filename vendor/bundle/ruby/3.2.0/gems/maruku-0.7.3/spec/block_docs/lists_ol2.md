Maruku handles some weirdly indented lists and paragraphs within lists.
*** Parameters: ***
{}
*** Markdown input: ***
1.  This is a list item with two paragraphs. Lorem ipsum dolor
    sit amet, consectetuer adipiscing elit. Aliquam hendrerit
    mi posuere lectus.

    ATTENZIONE!

    - Uno
    - Due
      1. tre
      1. tre
      1. tre
    - Due

2.  Suspendisse id sem consectetuer libero luctus adipiscing.


Ancora

*   This is a list item with two paragraphs.

    This is the second paragraph in the list item. You're
only required to indent the first line. Lorem ipsum dolor
sit amet, consectetuer adipiscing elit.

*   Another item in the same list.
*** Output of inspect ***
md_el(:document,[
	md_el(:ol,[
		md_li([
			md_par([
				"This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus."
			]),
			md_par(["ATTENZIONE!"]),
			md_el(:ul,[
				md_li(["Uno"],false),
				md_li(["Due",
					md_el(:ol,[
						md_li(["tre"],false),
						md_li(["tre"],false),
						md_li(["tre"],false)
					],{},[])
				],false),
				md_li(["Due"],false)
			],{},[])
		],true),
		md_li([
			md_par(["Suspendisse id sem consectetuer libero luctus adipiscing."])
		],false)
	],{},[]),
	md_par(["Ancora"]),
	md_el(:ul,[
		md_li([
			md_par(["This is a list item with two paragraphs."]),
			md_par([
				"This is the second paragraph in the list item. You",
				md_entity("rsquo"),
				"re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
			])
		],true),
		md_li([md_par(["Another item in the same list."])],false)
	],{},[])
],{},[])
*** Output of to_html ***
<ol>
<li>
<p>This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.</p>

<p>ATTENZIONE!</p>

<ul>
<li>Uno</li>

<li>Due
<ol>
<li>tre</li>

<li>tre</li>

<li>tre</li>
</ol>
</li>

<li>Due</li>
</ul>
</li>

<li>
<p>Suspendisse id sem consectetuer libero luctus adipiscing.</p>
</li>
</ol>

<p>Ancora</p>

<ul>
<li>
<p>This is a list item with two paragraphs.</p>

<p>This is the second paragraph in the list item. You’re only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</p>
</li>

<li>
<p>Another item in the same list.</p>
</li>
</ul>
*** Output of to_latex ***
\begin{enumerate}%
\item This is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.

ATTENZIONE!

\begin{itemize}%
\item Uno
\item Due\begin{enumerate}%
\item tre
\item tre
\item tre

\end{enumerate}

\item Due

\end{itemize}

\item Suspendisse id sem consectetuer libero luctus adipiscing.



\end{enumerate}
Ancora

\begin{itemize}%
\item This is a list item with two paragraphs.

This is the second paragraph in the list item. You're only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.


\item Another item in the same list.



\end{itemize}
*** Output of to_s ***
Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus. Vestibulum enim wisi, viverra nec, fringilla in, laoreet vitae, risus.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.Donec sit amet nisl. Aliquam semper ipsum sit amet velit. Suspendisse id sem consectetuer libero luctus adipiscing.AncoraThis is a list item with two paragraphs. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aliquam hendrerit mi posuere lectus.ATTENZIONE!UnoDuetretretreDueSuspendisse id sem consectetuer libero luctus adipiscing.AncoraThis is a list item with two paragraphs.This is the second paragraph in the list item. Youre only required to indent the first line. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.Another item in the same list.
