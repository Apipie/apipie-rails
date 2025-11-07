Block quotes can continue over multiple lines
*** Parameters: ***
{}
*** Markdown input: ***

> Here's a quote.
Which goes over two lines.

> It continues here.
> > And has a subquote.
{: style='color:red'}

> Here's a quote.
> Which goes over two lines.
{#foo}

> Here's a quote.
  Which goes over two lines.

*** Output of inspect ***
md_el(:document,[
	md_el(:quote,
		[md_par(["Here", md_entity("rsquo"), "s a quote. Which goes over two lines."]),
		 md_par(["It continues here."]),
		 md_el(:quote, md_par("And has a subquote."))
	],{},[[:style, "color:red"]]),
	md_el(:quote, md_par(["Here", md_entity("rsquo"), "s a quote. Which goes over two lines."]),{},[[:id, "foo"]]),
	md_el(:quote, md_par(["Here", md_entity("rsquo"), "s a quote. Which goes over two lines."]))
],{},[])
*** Output of to_html ***
<blockquote style="color:red">
  <p>Here’s a quote. Which goes over two lines.</p>
  <p>It continues here.</p>
  <blockquote>
    <p>And has a subquote.</p>
  </blockquote>
</blockquote>
<blockquote id="foo">
  <p>Here’s a quote. Which goes over two lines.</p>
</blockquote>
<blockquote>
  <p>Here’s a quote. Which goes over two lines.</p>
</blockquote>
*** Output of to_latex ***
\begin{quote}%
Here's a quote. Which goes over two lines.

It continues here.

\begin{quote}%
And has a subquote.


\end{quote}

\end{quote}
\begin{quote}%
Here's a quote. Which goes over two lines.


\end{quote}
\begin{quote}%
Here's a quote. Which goes over two lines.


\end{quote}