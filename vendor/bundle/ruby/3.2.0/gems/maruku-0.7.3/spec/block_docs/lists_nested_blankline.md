Nesting lists should handle newlines inbetween list items.
*** Parameters: ***
{} # params 
*** Markdown input: ***
* Bar
  * Bax

  * boo
*** Output of inspect ***
md_el(:document, md_el(:ul, [
	md_li([
	  md_par("Bar"),
	  md_el(:ul, [
	    md_li(md_par("Bax"), true),
	    md_li(md_par("boo"), false)
          ], {}, [])
       ],true)
],{},[]))
*** Output of to_html ***
<ul>
<li>
<p>Bar</p>

<ul>
<li>
<p>Bax</p>
</li>

<li>
<p>boo</p>
</li>
</ul>
</li>
</ul>
