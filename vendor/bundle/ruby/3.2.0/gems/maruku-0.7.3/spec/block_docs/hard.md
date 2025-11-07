More complicated tests for emphasis.
*** Parameters: ***
{}
*** Markdown input: ***
*This is in italic, and **this is bold italics**.*  But **is this bold and *this bold-italic* **? Or just plain ***bold italics***.
*** Output of inspect ***
md_el(:document,
  [md_par([
    md_em([
      "This is in italic, and ", md_strong(["this is bold italics"]), "."
    ]), " But ", md_strong([
                   "is this bold and ", md_em(["this bold-italic"])
                 ]), "? Or just plain ", md_emstrong(["bold italics"]), "."
   ])
  ],{},[])
*** Output of to_html ***
<p><em>This is in italic, and <strong>this is bold italics</strong>.</em> But <strong>is this bold and <em>this bold-italic</em></strong>? Or just plain <strong><em>bold italics</em></strong>.</p>
*** Output of to_latex ***
\emph{This is in italic, and \textbf{this is bold italics}.} But \textbf{is this bold and \emph{this bold-italic}}? Or just plain \textbf{\emph{bold italics}}.
*** Output of to_md ***
*This is in italic, and **this is bold italics**.*
But **is this bold and *this bold-italic* **? Or
just plain ***bold italics***.
*** Output of to_s ***
This is in italic, and this is bold italics. But is this bold and this bold-italic? Or just plain bold italics.
