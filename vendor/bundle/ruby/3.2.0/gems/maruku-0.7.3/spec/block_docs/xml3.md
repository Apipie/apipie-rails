The markdown="1" attribute does NOT get recursively applied
*** Parameters: ***
{}
*** Markdown input: ***
<table markdown='1'>
	Blah
	<thead>
		<tr><td>*em*</td></tr>
	</thead>
</table>

*** Output of inspect ***
md_el(:document,[
	md_html("<table markdown='1'>\n\tBlah\n\t<thead>\n\t\t<tr><td>*em*</td></tr>\n\t</thead>\n</table>")
],{},[])
*** Output of to_html ***
<table>
	Blah
	<thead>
		<tr><td>*em*</td></tr>
	</thead>
</table>


