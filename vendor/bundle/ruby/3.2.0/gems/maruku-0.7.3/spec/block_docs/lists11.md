Write a comment here
*** Parameters: ***
{} # params 
*** Markdown input: ***
- ένα

*** Output of inspect ***
md_el(:document,[
	md_el(:ul,[md_el(:li,["ένα"],{:want_my_paragraph=>false},[])],{},[])
],{},[])
*** Output of to_html ***
<ul>
<li>ένα</li>
</ul>
*** Output of to_latex ***
\begin{itemize}%
\item ένα

\end{itemize}
*** Output of to_md ***
- ένα
*** Output of to_s ***
ένα
