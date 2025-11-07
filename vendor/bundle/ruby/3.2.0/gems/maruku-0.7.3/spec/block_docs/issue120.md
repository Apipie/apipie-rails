Style tags should be OK with unescaped angle brackets and ampersands. https://github.com/bhollis/maruku/issues/120
NOTE: Commented CDATA is output because we use XHTML - for HTML mode it should be omitted.
*** Parameters: ***
{}
*** Markdown input: ***
<style type="text/css">
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
</style>

<style type="text/css">/*<![CDATA[*/
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
/*]]>*/</style>

<style type="text/css">
/*<![CDATA[*/
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
/*]]>*/
</style>
*** Output of inspect ***

*** Output of to_html ***
<style type='text/css'>/*<![CDATA[*/
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
/*]]>*/</style><style type='text/css'>/*<![CDATA[*/
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
/*]]>*/</style><style type='text/css'>
/*<![CDATA[*/
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
/*]]>*/
</style>
