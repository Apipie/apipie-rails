Write a comment abouth the test here.
*** Parameters: ***
{}
*** Markdown input: ***
> Code
>
>     Ciao
*** Output of inspect ***
md_el(:document,[
	md_el(:quote,[md_par(["Code"]), md_el(:code,[],{:raw_code=>"Ciao", :lang=>nil},[])],{},[])
],{},[])
*** Output of to_html ***
<blockquote>
<p>Code</p>

<pre><code>Ciao</code></pre>
</blockquote>
*** Output of to_latex ***
\begin{quote}%
Code

\begin{verbatim}Ciao\end{verbatim}

\end{quote}
*** Output of to_md ***
> Code
> 
>      Ciao
*** Output of to_s ***
Code
