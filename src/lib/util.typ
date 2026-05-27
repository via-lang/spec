
#let secref(lbl) = context {
  let results = query(lbl)
  if results.len() == 0 {
    text(fill: red)[⚠#str(lbl)]
  } else {
    let h = results.first()
    let num = counter(heading).at(h.location()).map(str).join(".")
    link(lbl, text(fill: blue.darken(20%), underline(
      stroke: (paint: blue.darken(20%), dash: "dotted"),
      [#sym.section #num #sym.dot #h.body],
    )))
  }
}
