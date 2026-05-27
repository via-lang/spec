#import "util.typ": secref

#let generic(name, bounds: (), default: none) = (
  kind: "typename",
  name: name,
  bounds: bounds,
  default: default,
)

#let const-generic(name, type, default: none) = (
  kind: "const",
  name: name,
  type: type,
  default: default,
)

#let render-generics(gs) = context {
  if gs.len() > 0 [
    #v(2pt)
    #table(
      columns: (auto, auto, auto),
      stroke: none,
      inset: (x: 6pt, y: 5pt),
      fill: (_, row) => if row == 0 {
        luma(220)
      } else if calc.odd(row) {
        luma(245)
      } else {
        none
      },

      [*Parameter*], [*Bounds*], [*Default*],

      ..gs
        .map(g => {
          let def-val = g.at("default", default: none)
          let default-cell = if def-val != none { raw(str(def-val), lang: "rs") } else { [-] }

          if g.at("kind", default: "type") == "const" {
            let param-cell = raw("const " + g.name, lang: "rs")
            let type-lbl = label("type-" + lower(g.type))
            let type-cell = link(type-lbl, raw(g.type))

            (param-cell, type-cell, default-cell)
          } else {
            let param-cell = raw(g.name)
            let bounds-cell = if g.bounds.len() > 0 {
              g
                .bounds
                .map(b => {
                  let lbl = label("trait-" + lower(b.replace("?", "")))
                  link(lbl, raw(b, lang: "rs"))
                })
                .join(" + ")
            } else {
              [-]
            }

            (param-cell, bounds-cell, default-cell)
          }
        })
        .flatten(),
    )
  ]
}

#let render-signature(kind, name, generics, fmt: none) = {
  let formatted-params = generics.map(g => {
    let def-val = g.at("default", default: none)
    let def-str = if def-val != none { " = " + str(def-val) } else { "" }

    if g.at("kind", default: "type") == "const" {
      "const " + g.name + ": " + g.type + def-str
    } else {
      g.name + def-str
    }
  })

  let sig-text = if fmt != none {
    let result = fmt
    for (idx, param) in formatted-params.enumerate() {
      result = result.replace("%" + str(idx), param)
    }
    result
  } else {
    if formatted-params.len() > 0 {
      name + "<" + formatted-params.join(", ") + ">"
    } else {
      name
    }
  }

  [
    *Signature*
    #raw(kind + " " + sig-text, lang: "rs")
  ]
}
