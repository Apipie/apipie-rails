Maruku should not unnecessarily wrap <li>'s in <p>
*** Parameters: ***
{} # params 
*** Markdown input: ***
- Due
  1. tre
  1. tre
  1. tre
- Due
*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[
		md_el(:li,[
			"Due",
			md_el(:ol,[
				md_el(:li,["tre"],{:want_my_paragraph=>false},[]),
				md_el(:li,["tre"],{:want_my_paragraph=>false},[]),
				md_el(:li,["tre"],{:want_my_paragraph=>false},[])
			],{},[])
		],{:want_my_paragraph=>false},[]),
		md_el(:li,["Due"],{:want_my_paragraph=>false},[])
	],{},[])
],{},[])
*** Output of to_html ***
<ul>
<li>Due
<ol>
<li>tre</li>
<li>tre</li>
<li>tre</li>
</ol></li>
<li>Due</li>
</ul>

*** Output of to_latex ***
\begin{itemize}%
\item Due\begin{enumerate}%
\item tre
\item tre
\item tre

\end{enumerate}

\item Due

\end{itemize}
*** Output of to_md ***
-ue* tre
* tre
* tre
-ue
*** Output of to_s ***
DuetretretreDue
