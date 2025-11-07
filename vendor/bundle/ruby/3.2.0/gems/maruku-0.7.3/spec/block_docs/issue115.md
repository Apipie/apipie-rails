Markdown in comments should not be parsed. https://github.com/bhollis/maruku/issues/115
Note that output is kind of weird because we modify the comment in order to let REXML parse it due to https://bugs.ruby-lang.org/issues/9277.
*** Parameters: ***
{}
*** Markdown input: ***
<!--
Header
------
-->

<!-- -- -->
*** Output of inspect ***
md_el(:document,[md_html("<!--\nHeader\n- - - - - - \n-->"), md_html("<!-- - - -->")])
*** Output of to_html ***
<!--
Header
- - - - - - 
-->

<!-- - - -->
