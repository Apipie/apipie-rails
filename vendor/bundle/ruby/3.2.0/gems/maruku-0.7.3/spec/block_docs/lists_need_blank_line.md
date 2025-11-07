list syntax needs a newline before it to be a valid list!
*** Parameters: ***
{}
*** Markdown input: ***
This is not a list:
* one
* two

This is a list:

* one
* two

This is a list:

* one
ciao

This is a list:

1. one
1. two

This is a list:

1987. one
ciao


*** Output of inspect ***
md_el(:document,[
	md_par(["This is not a list: * one * two"]),
	md_par(["This is a list:"]),
	md_el(:ul,[md_li("one", false), md_li("two", false)],{},[]),
	md_par(["This is a list:"]),
  md_el(:ul,md_li("one ciao", false),{},[]),
	md_par(["This is a list:"]),
	md_el(:ol,[md_li("one", false), md_li("two", false)],{},[]),
  md_par(["This is a list:"]),
	md_el(:ol,md_li("one ciao", false),{},[])
],{},[])
*** Output of to_html ***
<p>This is not a list: * one * two</p>

<p>This is a list:</p>

<ul>
<li>one</li>

<li>two</li>
</ul>

<p>This is a list:</p>

<ul>
<li>one ciao</li>
</ul>

<p>This is a list:</p>

<ol>
<li>one</li>

<li>two</li>
</ol>

<p>This is a list:</p>

<ol>
<li>one ciao</li>
</ol>
*** Output of to_latex ***
This is not a list: * one * two

This is a list:

\begin{itemize}%
\item one
\item two

\end{itemize}
This is a list:

\begin{itemize}%
\item one ciao

\end{itemize}
This is a list:

\begin{enumerate}%
\item one
\item two

\end{enumerate}
This is a list:

\begin{enumerate}%
\item one ciao

\end{enumerate}
*** Output of to_md ***
This is a list:

-ne
-wo

This is not a list: * one ciao

This is a list:

1.  one
2.  two

This is not a list: 1987. one ciao
*** Output of to_s ***
This is a list:onetwoThis is not a list: * one ciaoThis is a list:onetwoThis is not a list: 1987. one ciao
