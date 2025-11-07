JRUBY NOKOGIRI PENDING - MathML inline with HTML
(JRuby Nokogiri is broken for empty tags: https://github.com/sparklemotion/nokogiri/issues/971)
*** Parameters: ***
{}
*** Markdown input: ***
In <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" class="maruku-mathml"><mi>SU</mi><mo stretchy="false">(</mo><mn>3</mn><mo stretchy="false">)</mo></math>, <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" class="maruku-mathml"><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics><mo>=</mo><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics></math>.

<math xmlns="http://www.w3.org/1998/Math/MathML" display="block" class="maruku-mathml"><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics><mo>=</mo><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics></math>

*** Output of inspect ***
md_el(:document,[
	md_par(["In ",
	  md_html("<math xmlns=\"http://www.w3.org/1998/Math/MathML\" display=\"inline\" class=\"maruku-mathml\"><mi>SU</mi><mo stretchy=\"false\">(</mo><mn>3</mn><mo stretchy=\"false\">)</mo></math>"),
	  ", ",
	  md_html("<math xmlns=\"http://www.w3.org/1998/Math/MathML\" display=\"inline\" class=\"maruku-mathml\"><semantics><annotation-xml encoding=\"SVG1.1\">\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30\" height=\"16\" viewBox=\"0 0 30 16\">\n  <desc>Rank-2 Symmetric Tensor Representation</desc>\n  <g transform=\"translate(5,5)\" fill=\"#FCC\" stroke=\"#000\" stroke-width=\"2\">\n    <rect width=\"10\" height=\"10\"></rect>\n    <rect width=\"10\" height=\"10\" x=\"10\"></rect>\n  </g>\n</svg>\n</annotation-xml></semantics><mo>=</mo><semantics><annotation-xml encoding=\"SVG1.1\">\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30\" height=\"16\" viewBox=\"0 0 30 16\">\n  <desc>Rank-2 Symmetric Tensor Representation</desc>\n  <g transform=\"translate(5,5)\" fill=\"#FCC\" stroke=\"#000\" stroke-width=\"2\">\n    <rect width=\"10\" height=\"10\"></rect>\n    <rect width=\"10\" height=\"10\" x=\"10\"></rect>\n  </g>\n</svg>\n</annotation-xml></semantics></math>"),
	  "."
	  ]),
	  md_html("<math xmlns=\"http://www.w3.org/1998/Math/MathML\" display=\"block\" class=\"maruku-mathml\"><semantics><annotation-xml encoding=\"SVG1.1\">\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30\" height=\"16\" viewBox=\"0 0 30 16\">\n  <desc>Rank-2 Symmetric Tensor Representation</desc>\n  <g transform=\"translate(5,5)\" fill=\"#FCC\" stroke=\"#000\" stroke-width=\"2\">\n    <rect width=\"10\" height=\"10\"></rect>\n    <rect width=\"10\" height=\"10\" x=\"10\"></rect>\n  </g>\n</svg>\n</annotation-xml></semantics><mo>=</mo><semantics><annotation-xml encoding=\"SVG1.1\">\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30\" height=\"16\" viewBox=\"0 0 30 16\">\n  <desc>Rank-2 Symmetric Tensor Representation</desc>\n  <g transform=\"translate(5,5)\" fill=\"#FCC\" stroke=\"#000\" stroke-width=\"2\">\n    <rect width=\"10\" height=\"10\"></rect>\n    <rect width=\"10\" height=\"10\" x=\"10\"></rect>\n  </g>\n</svg>\n</annotation-xml></semantics></math>")
],{},[])
*** Output of to_html ***
<p>In <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" class="maruku-mathml"><mi>SU</mi><mo stretchy="false">(</mo><mn>3</mn><mo stretchy="false">)</mo></math>, <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" class="maruku-mathml"><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics><mo>=</mo><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics></math>.</p>

<math xmlns="http://www.w3.org/1998/Math/MathML" display="block" class="maruku-mathml"><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics><mo>=</mo><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <desc>Rank-2 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
  </g>
</svg>
</annotation-xml></semantics></math>
