Lists should be nestable to arbitrary depth.
*** Parameters: ***
{}
*** Markdown input: ***
* Space
  * Space
    * Space
      * Space
        * Space

*** Output of inspect ***
md_el(:document, [
	md_el(:ul, md_li([
	"Space",
	md_el(:ul, md_li([
	"Space",
	md_el(:ul, md_li([
	"Space",
	md_el(:ul, md_li(["Space", md_el(:ul, md_li("Space", false))], false))
], false))
], false))
], false))
])
*** Output of to_html ***
<ul>
<li>Space
<ul>
<li>Space
<ul>
<li>Space
<ul>
<li>Space
<ul>
<li>Space</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
</li>
</ul>
