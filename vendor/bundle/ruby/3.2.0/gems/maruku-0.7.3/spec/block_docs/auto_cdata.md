Adds CDATA only when necessary.
NOTE: CDATA is output because we use XHTML - for HTML mode it should be omitted.
*** Parameters: ***
{}
*** Markdown input: ***
<script>
  var x = true && true;
</script>

<script>
  var x = true;
</script>

<script>foo && bar</script>

<script>alert('foo');</script>

<style type="text/css">
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
</style>

<style type="text/css">
  .highlight {
    color: red;
  }
</style>
*** Output of inspect ***

*** Output of to_html ***
<script>//<![CDATA[
  var x = true && true;
//]]></script><script>
  var x = true;
</script><script>//<![CDATA[
foo && bar
//]]></script><script>alert('foo');</script><style type='text/css'>/*<![CDATA[*/
  p > .highlight {
    color: red;
    background-image: url('/foo?bar&baz');
  }
/*]]>*/</style><style type='text/css'>
  .highlight {
    color: red;
  }
</style>
