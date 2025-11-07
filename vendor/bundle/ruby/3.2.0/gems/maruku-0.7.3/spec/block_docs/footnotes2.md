Write a comment abouth the test here.
*** Parameters: ***
require 'maruku/ext/math';{:html_math_engine => 'itex2mml'}
*** Markdown input: ***
Ruby on Rails is a web-framework[^framework]. It uses the MVC[^MVC] architecture pattern. It has its good points[^points].

[^framework]: a reusable set of libraries
[^MVC]: Model View Controller
[^points]: Here are its good points

     1. Ease of use
     2. Rapid development

That has nothing to do with putting equations in footnotes[^equations].

[^equations]: Like this:
$$
  x = r\cos\theta
$$
*** Output of inspect ***
md_el(:document,[
	md_par([
		"Ruby on Rails is a web-framework",
		md_foot_ref("^framework"),
		". It uses the MVC",
		md_foot_ref("^MVC"),
		" architecture pattern. It has its good points",
		md_foot_ref("^points"),
		"."
	]),
	md_el(:footnote, md_par("a reusable set of libraries"), {:footnote_id=>"^framework"}),
	md_el(:footnote, md_par("Model View Controller"), {:footnote_id=>"^MVC"}),
	md_el(:footnote, [
		md_par("Here are its good points"),
		md_el(:ol, [md_li("Ease of use", false), md_li("Rapid development", false)])
		], {:footnote_id=>"^points"}),
	md_par([
		"That has nothing to do with putting equations in footnotes",
		md_foot_ref("^equations"),
		"."
		]),
	md_el(:footnote, [
		md_par("Like this:"),
		md_el(:equation, [], {:math=>"\nx = r\\cos\\theta\n\n", :label=>nil, :num=>nil})
		], {:footnote_id=>"^equations"})
],{},[])
*** Output of to_html ***
<p>Ruby on Rails is a web-framework<sup id="fnref:1"><a href="#fn:1" rel="footnote">1</a></sup>. It uses the MVC<sup id="fnref:2"><a href="#fn:2" rel="footnote">2</a></sup> architecture pattern. It has its good points<sup id="fnref:3"><a href="#fn:3" rel="footnote">3</a></sup>.</p>

<p>That has nothing to do with putting equations in footnotes<sup id="fnref:4"><a href="#fn:4" rel="footnote">4</a></sup>.</p>
<div class="footnotes"><hr /><ol><li id="fn:1">
<p>a reusable set of libraries <a href="#fnref:1" rev="footnote">↩</a></p>
</li><li id="fn:2">
<p>Model View Controller <a href="#fnref:2" rev="footnote">↩</a></p>
</li><li id="fn:3">
<p>Here are its good points</p>

<ol>
<li>Ease of use</li>

<li>Rapid development</li>
</ol>
<a href="#fnref:3" rev="footnote">↩</a></li><li id="fn:4">
<p>Like this:</p>
<div class="maruku-equation"><math xmlns="http://www.w3.org/1998/Math/MathML" display="block" class="maruku-mathml"><semantics><mrow><mi>x</mi><mo>=</mo><mi>r</mi><mi>cos</mi><mi>θ</mi></mrow><annotation encoding="application/x-tex">
x = r\cos\theta

</annotation></semantics></math></div><a href="#fnref:4" rev="footnote">↩</a></li></ol></div>
*** Output of to_latex ***
Ruby on Rails is a web-framework\footnote{a reusable set of libraries} . It uses the MVC\footnote{Model View Controller}  architecture pattern. It has its good points\footnote{Here are its good points

\begin{enumerate}%
\item Ease of use
\item Rapid development

\end{enumerate}} .

That has nothing to do with putting equations in footnotes\footnote{Like this:

\begin{displaymath}
x = r\cos\theta
\end{displaymath}} .