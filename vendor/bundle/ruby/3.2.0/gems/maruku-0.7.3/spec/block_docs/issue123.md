Handle script tag without a newline. https://github.com/bhollis/maruku/issues/123
*** Parameters: ***
{ }
*** Markdown input: ***
Lets add Jade to our dependencies:
<script src="https://gist.github.com/7360992.js"> </script>
*** Output of inspect ***

*** Output of to_html ***
<p>Lets add Jade to our dependencies:</p>
<script src='https://gist.github.com/7360992.js'> </script>
