List Items with non alphanumeric content
*** Parameters: ***
{}
*** Markdown input: ***
* {: #foo} A
* {: #bar } ?
* {#fubar} B
* {#fubar2 } C
* {Not an IAL}

*** Output of inspect ***
md_el(:document,[
  md_el(:ul,[
   md_el(:li,["A"],{:want_my_paragraph=>false},[[:id, "foo"]]),
   md_el(:li,["?"],{:want_my_paragraph=>false},[[:id, "bar"]]),
   md_el(:li,["B"],{:want_my_paragraph=>false},[[:id, "fubar"]]),
   md_el(:li,["C"],{:want_my_paragraph=>false},[[:id, "fubar2"]]),
   md_el(:li,["{Not an IAL}"],{:want_my_paragraph=>false},[])
   ],{},[]),
],{},[])

*** Output of to_html ***
<ul>
<li id="foo">A</li>

<li id="bar">?</li>

<li id="fubar">B</li>

<li id="fubar2">C</li>

<li>{Not an IAL}</li>
</ul>

*** Output of to_latex ***
\begin{itemize}%
\item A
\item ?
\item B
\item C
\item \{Not an IAL\}

\end{itemize}

*** Output of to_md ***
- A
- ?
- B
- C
- {Not an IAL}

*** Output of to_s ***
A?BC{Not an IAL}


