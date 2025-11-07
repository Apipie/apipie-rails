List Items with non alphanumeric content. https://github.com/bhollis/maruku/issues/1
*** Parameters: ***
{}
*** Markdown input: ***
* A
* ?
* B

*** Output of inspect ***
md_el(:document,[
  md_el(:ul,[
    md_el(:li,["A"],{:want_my_paragraph=>false},[]),
    md_el(:li,["?"],{:want_my_paragraph=>false},[]),
    md_el(:li,["B"],{:want_my_paragraph=>false},[])
  ],{},[])
],{},[])

*** Output of to_html ***
<ul>
<li>A</li>

<li>?</li>

<li>B</li>
</ul>

*** Output of to_latex ***
\begin{itemize}%
\item A
\item ?
\item B

\end{itemize}

*** Output of to_md ***
- A
- ?
- B

*** Output of to_s ***
A?B


