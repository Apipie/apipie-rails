JRUBY NOKOGIRI PENDING - Maruku should nest inline-level HTML inside a paragraph
(JRuby Nokogiri is broken for empty tags: https://github.com/sparklemotion/nokogiri/issues/971)
*** Parameters: ***
{} # params
*** Markdown input: ***
One
<span></span>123

<span></span>123

<animateColor/>123

<svg></svg>
*** Output of inspect ***
md_el(:document,[
	md_par(["One ", md_html("<span></span>"), "123"]),
	md_par([md_html("<span></span>"), "123"]),
	md_par([md_html("<animateColor/>"), "123"]),
	md_html("<svg></svg>"),
],{},[])
*** Output of to_html ***
<p>One <span></span>123</p>
<p><span></span>123</p>
<p><animateColor></animateColor>123</p>
<svg></svg>
