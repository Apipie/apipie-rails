Comment
*** Parameters: ***
require 'maruku/ext/math'; {:math_enabled => true}
*** Markdown input: ***

This is a single citation: \cite{Foo1993}.  This contains multiple citations: \cite{Foo1993,Bar, Baz22}.

Here are some cites that match INSPIRE and MathSciNet: \cite{chacaltana:2010ks, MR3046557, fubar,Chacaltana:2014ica}.

How about a blank \cite{}? Or \cite{,}?

*** Output of inspect ***
md_el(:document,[
        md_par(["This is a single citation: ",
		   md_el(:citation, [], {:cites=>["Foo1993"]}), ". This contains multiple citations: ",
		   md_el(:citation, [], {:cites=>["Foo1993", "Bar", "Baz22"]}), "."
		]),
		md_par(["Here are some cites that match INSPIRE and MathSciNet: ",
		   md_el(:citation, [], {:cites=>["chacaltana:2010ks", "MR3046557", "fubar", "Chacaltana:2014ica"]}),
		   "."
		]),
		md_par(["How about a blank ", md_el(:citation, [], {:cites=>[]}),
		   "? Or ", md_el(:citation, [], {:cites=>[]}), "?"
		])
],{},[])
*** Output of to_html ***
<p>This is a single citation: <span class="maruku-citation">[Foo1993]</span>. This contains multiple citations: <span class="maruku-citation">[Foo1993,Bar,Baz22]</span>.</p>

<p>Here are some cites that match INSPIRE and MathSciNet: <span class="maruku-citation">[<a href="http://inspirehep.net/search?p=chacaltana%3A2010ks">chacaltana:2010ks</a>,<a href="http://www.ams.org/mathscinet-getitem?mr=3046557">MR3046557</a>,fubar,<a href="http://inspirehep.net/search?p=Chacaltana%3A2014ica">Chacaltana:2014ica</a>]</span>.</p>

<p>How about a blank <span class="maruku-citation">[]</span>? Or <span class="maruku-citation">[]</span>?</p>
*** Output of to_latex ***
This is a single citation: \cite{Foo1993}. This contains multiple citations: \cite{Foo1993,Bar,Baz22}.

Here are some cites that match INSPIRE and MathSciNet: \cite{chacaltana:2010ks,MR3046557,fubar,Chacaltana:2014ica}.

How about a blank \cite{}? Or \cite{}?