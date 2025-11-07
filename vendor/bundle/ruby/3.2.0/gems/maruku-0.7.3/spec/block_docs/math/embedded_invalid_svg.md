REXML PENDING - This tests that invalid SVG within LaTeX gets corrected and still output. I'm not sure why it should do that.
Pending because Nokogiri will handle the tagsoup but REXML won't.
TODO: The LaTeX output does not look correct here!
*** Parameters: ***
require 'maruku/ext/math'; {:html_math_engine => 'itex2mml'}
*** Markdown input: ***
 In $SU(3)$, $\begin{svg}
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <g></rect>
</svg>
\end{svg}\includegraphics[width=2em]{young1}
 \otimes
\begin{svg}
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="16" viewBox="0 0 20 16">
  <desc>Fundamental Representation</desc>
  <g>
</svg>
\end{svg}\includegraphics[width=1em]{young2}
 =
\begin{svg}
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="26" viewBox="0 0 30 26">
  <desc>Adjoint Representation</desc>
  </g>
</svg>
\end{svg}\includegraphics[width=2em]{young3}
 \oplus
\begin{svg}
<svg xmlns="http://www.w3.org/2000/svg" width="40" height="16" viewBox="0 0 40 16">
  <desc>Rank-3 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"/>
    <rect width="10" height="10" x="10"/>
    <rect width="10" height="10" x="20"/>
  </g>
</svg>
\end{svg}\includegraphics[width=3em]{young4}$.

*** Output of inspect ***
md_el(:document,[
	md_par(["In ",
	  md_el(:inline_math, [], {:math=>"SU(3)"}),
	  ", ",
	  md_el(:inline_math, [], {:math=>"\\begin{svg}\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30\" height=\"16\" viewBox=\"0 0 30 16\">\n  <g></rect>\n</svg>\n\\end{svg}\\includegraphics[width=2em]{young1}\n \\otimes\n\\begin{svg}\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"20\" height=\"16\" viewBox=\"0 0 20 16\">\n  <desc>Fundamental Representation</desc>\n  <g>\n</svg>\n\\end{svg}\\includegraphics[width=1em]{young2}\n =\n\\begin{svg}\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"30\" height=\"26\" viewBox=\"0 0 30 26\">\n  <desc>Adjoint Representation</desc>\n  </g>\n</svg>\n\\end{svg}\\includegraphics[width=2em]{young3}\n \\oplus\n\\begin{svg}\n<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"40\" height=\"16\" viewBox=\"0 0 40 16\">\n  <desc>Rank-3 Symmetric Tensor Representation</desc>\n  <g transform=\"translate(5,5)\" fill=\"#FCC\" stroke=\"#000\" stroke-width=\"2\">\n    <rect width=\"10\" height=\"10\"/>\n    <rect width=\"10\" height=\"10\" x=\"10\"/>\n    <rect width=\"10\" height=\"10\" x=\"20\"/>\n  </g>\n</svg>\n\\end{svg}\\includegraphics[width=3em]{young4}"}),
	  "."
	  ])
],{},[])
*** Output of to_html ***
<p>In <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" class="maruku-mathml"><semantics><mrow><mi>SU</mi><mo stretchy="false">(</mo><mn>3</mn><mo stretchy="false">)</mo></mrow><annotation encoding="application/x-tex">SU(3)</annotation></semantics></math>, <math xmlns="http://www.w3.org/1998/Math/MathML" display="inline" class="maruku-mathml"><semantics><mrow><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="16" viewBox="0 0 30 16">
  <g></g>
</svg>
</annotation-xml></semantics><mo>⊗</mo><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="20" height="16" viewBox="0 0 20 16">
  <desc>Fundamental Representation</desc>
  <g>
</g>
</svg></annotation-xml><mo>=</mo><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="30" height="26" viewBox="0 0 30 26">
  <desc>Adjoint Representation</desc>
  </svg>
</annotation-xml>
</semantics></semantics><mo>⊕</mo><semantics><annotation-xml encoding="SVG1.1">
<svg xmlns="http://www.w3.org/2000/svg" width="40" height="16" viewBox="0 0 40 16">
  <desc>Rank-3 Symmetric Tensor Representation</desc>
  <g transform="translate(5,5)" fill="#FCC" stroke="#000" stroke-width="2">
    <rect width="10" height="10"></rect>
    <rect width="10" height="10" x="10"></rect>
    <rect width="10" height="10" x="20"></rect>
  </g>
</svg>
</annotation-xml></semantics></mrow><annotation encoding="application/x-tex">\begin{svg}
svg xmlns=http://www.w3.org/2000/svg width=30 height=16 viewBox=0 0 30 16
  g/rect
/svg
\end{svg}\includegraphics[width=2em]{young1}
 \otimes
\begin{svg}
svg xmlns=http://www.w3.org/2000/svg width=20 height=16 viewBox=0 0 20 16
  descFundamental Representation/desc
  g
/svg
\end{svg}\includegraphics[width=1em]{young2}
 =
\begin{svg}
svg xmlns=http://www.w3.org/2000/svg width=30 height=26 viewBox=0 0 30 26
  descAdjoint Representation/desc
  /g
/svg
\end{svg}\includegraphics[width=2em]{young3}
 \oplus
\begin{svg}
svg xmlns=http://www.w3.org/2000/svg width=40 height=16 viewBox=0 0 40 16
  descRank-3 Symmetric Tensor Representation/desc
  g transform=translate(5,5) fill=#FCC stroke=#000 stroke-width=2
    rect width=10 height=10/
    rect width=10 height=10 x=10/
    rect width=10 height=10 x=20/
  /g
/svg
\end{svg}\includegraphics[width=3em]{young4}</annotation></semantics></math>.</p>
*** Output of to_latex ***
In $SU(3)$, $ \includegraphics[width=2em]{young1}
 \otimes
 \includegraphics[width=1em]{young2}
 =
 \includegraphics[width=2em]{young3}
 \oplus
 \includegraphics[width=3em]{young4}$.
