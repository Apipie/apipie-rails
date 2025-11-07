Handle HTTPS links at the start of a line. https://github.com/bhollis/maruku/issues/126
*** Parameters: ***
{ }
*** Markdown input: ***
<https://google.com>
*** Output of inspect ***

*** Output of to_html ***
<p><a href="https://google.com">https://google.com</a></p>
