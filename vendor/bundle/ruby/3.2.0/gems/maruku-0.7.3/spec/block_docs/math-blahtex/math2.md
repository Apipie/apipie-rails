
*** Parameters: ***
require 'maruku/ext/math'
{:math_numbered => ['\\['], :html_math_engine => 'blahtex' }
*** Markdown input: ***

\[
	\alpha
\]

\begin{equation}
	\alpha
\end{equation}

\begin{equation} \beta
\end{equation}


\begin{equation} \gamma \end{equation}
*** Output of inspect ***
md_el(:document,[
	md_el(:equation,[],{:label=>"eq1",:math=>"\n\t\\alpha\n\n",:num=>1},[]),
	md_el(:equation,[],{:label=>nil,:math=>"\n\t\\alpha\n\n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" \\beta\n\n",:num=>nil},[]),
	md_el(:equation,[],{:label=>nil,:math=>" \\gamma ",:num=>nil},[])
],{},[])
*** Output of to_html ***
<div class="maruku-equation" id="eq:eq1"><span class="maruku-eq-number">(1)</span><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mi>&#x3b1;</mi>
</math></div><div class="maruku-equation"><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mi>&#x3b1;</mi>
</math></div><div class="maruku-equation"><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mi>&#x3b2;</mi>
</math></div><div class="maruku-equation"><math class='maruku-mathml' display='block' xmlns='http://www.w3.org/1998/Math/MathML'>
<mi>&#x3b3;</mi>
</math></div>
*** Output of to_latex ***
\begin{equation}
\alpha
\label{eq1}\end{equation}
\begin{displaymath}
\alpha
\end{displaymath}
\begin{displaymath}
\beta
\end{displaymath}
\begin{displaymath}
\gamma
\end{displaymath}
*** Output of to_md ***

*** Output of to_s ***
