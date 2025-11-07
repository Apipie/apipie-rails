Script tags should be OK with unescaped ampersands. https://github.com/bhollis/maruku/issues/40
NOTE: CDATA is output because we use XHTML - for HTML mode it should be omitted.
*** Parameters: ***
{}
*** Markdown input: ***
<script>
  var x = true && true;
</script>

<script>foo && bar</script>

<script><![CDATA[
  var x = true && true;
]]></script>

<script><![CDATA[foo && bar]]></script>

<script>
<![CDATA[
  var x = true && true;
]]>
</script>

<script>//<![CDATA[
  var x = true && true;
//]]></script>

<script>
//<![CDATA[
  var x = true && true;
//]]>
</script>
*** Output of inspect ***

*** Output of to_html ***
<script>//<![CDATA[
  var x = true && true;
//]]></script><script>//<![CDATA[
foo && bar
//]]></script><script><![CDATA[
  var x = true && true;
]]></script><script><![CDATA[foo && bar]]></script><script>
<![CDATA[
  var x = true && true;
]]>
</script><script>//<![CDATA[
  var x = true && true;
//]]></script><script>
//<![CDATA[
  var x = true && true;
//]]>
</script>
