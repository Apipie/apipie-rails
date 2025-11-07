Nested Lists with IALs
*** Parameters: ***
{}
*** Markdown input: ***
1. First
   * {: #bar} A
   * B
2. {: .foo} Second
   * C
   * D
3. {:fubar style="color:red"} Third

*** Output of inspect ***
md_el(:document, [
  md_el(:ol, [
    md_li(["First",
      md_el(:ul, [
        md_li("A", false, [[:id, "bar"]]),
        md_li("B", false)
      ], {}, [])
     ], false),
    md_li([
      "Second",
      md_el(:ul, [md_li("C", false), md_li("D", false)],{},[])
     ], false, [[:class, "foo"]]),
    md_li("Third", false, [[:ref, "fubar"],["style", "color:red"]])
   ],{},[])
],{},[])

*** Output of to_html ***
<ol>
<li>First
<ul>
<li id="bar">A</li>
<li>B</li>
</ul>
</li>
<li class="foo">Second
<ul>
<li>C</li>
<li>D</li>
</ul></li>
<li style="color:red">Third</li>
</ol>
*** Output of to_latex ***
\begin{enumerate}%
\item First\begin{itemize}%
\item A
\item B

\end{itemize}

\item Second\begin{itemize}%
\item C
\item D

\end{itemize}

\item Third

\end{enumerate}
