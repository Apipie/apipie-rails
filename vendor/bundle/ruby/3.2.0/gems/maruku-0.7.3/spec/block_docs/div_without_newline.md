Handle blocks of block HTML without a newline. https://github.com/bhollis/maruku/issues/123
REXML won't clean up the HTML the way Nokogiri will...
*** Parameters: ***
{ }
*** Markdown input: ***
Heres some HTML.
<div>
Foo
</div>
*** Output of inspect ***

*** Output of to_html ***
<p>Heres some HTML.</p>
<div>
Foo
</div>
