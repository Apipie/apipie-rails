
*** Parameters: ***
require 'maruku/ext/math'; {:html_math_engine => 'itex2mml'}
*** Markdown input: ***
This *is* $a * b * c$ ahem.
*** Output of inspect ***
md_el(:document, md_par([
        "This ",
        md_em("is"),
        " ",
        md_el(:inline_math, [], {:math=>"a * b * c"}),
        " ahem."
]))
*** Output of to_html ***
<p>This <em>is</em> <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" class="maruku-mathml"><semantics><mrow><mi>a</mi><mo>*</mo><mi>b</mi><mo>*</mo><mi>c</mi></mrow><annotation encoding="application/x-tex">a * b * c</annotation></semantics></math> ahem.</p>
*** Output of to_latex ***
This \emph{is} $a * b * c$ ahem.
