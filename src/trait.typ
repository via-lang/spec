#import "@preview/note-me:0.6.0": *
#import "lib/util.typ": secref
#import "lib/generic.typ": const-generic, generic, render-generics, render-signature
#import "lib/function.typ": function

#let trait(
  name,
  desc,
  example,
  auto-trait: false,
  user-implementable: false,
  generics: (),
  types: (),
  consts: (),
  methods: (),
) = [
  #heading(level: 2)[#name] #label("trait-" + lower(name))
  #block(
    fill: luma(100%, 0%),
    inset: 8pt,
    width: 100%,
  )[
    #desc

    #render-signature(if auto-trait { "auto trait" } else { "trait" }, name, generics)
    #render-generics(generics)

    #if types.len() > 0 [
      *Associated Types*
      #render-generics(types)
    ]

    #if consts.len() > 0 [
      *Associated Consts*
      #table(
        stroke: none,
        inset: (x: 6pt, y: 4pt),
        fill: (_, row) => if calc.odd(row) { luma(100%, 0%) } else { none },
        columns: (auto, 1fr),
        ..consts.map(c => (raw(c.name), c.desc)).flatten()
      )
    ]

    #if methods.len() > 0 [
      *Methods*
      #table(
        stroke: none,
        inset: (x: 6pt, y: 4pt),
        fill: (_, row) => if calc.odd(row) { luma(100%, 0%) } else { none },
        columns: (auto, auto),
        ..methods.map(m => (raw(m.sig, lang: "rs"), m.desc)).flatten()
      )
    ]

    *Implementable* #if user-implementable { "Yes" } else { "No" }

    *Examples*
    #example
  ]
]

= Traits <trait>

#trait(
  "Defined",
  [A blanket auto trait that is implemented for every type except #secref(label("type-unit")).],
  ```rs
    trait Foo = [()]; // Error: () does not implement `Defined`
  ```,
  auto-trait: true,
  user-implementable: false,
)

#trait(
  "Clone",
  "Provides a way to clone values.",
  ```rs
    fn clone<T: Clone>(t: T) -> T {
        t.clone()
    }
  ```,
  user-implementable: true,
  methods: (
    function("fn clone(&self) -> Self", "clone"),
  ),
)

#trait(
  "Default",
  "default",
  ```rs
  ```,
  user-implementable: true,
  methods: (
    function("fn default() -> Self", "default"),
  ),
)

#trait(
  "Add",
  "add",
  ```rs
  ```,
  user-implementable: true,
  generics: (
    generic("Rhs", default: "Self"),
  ),
  types: (
    generic("Output"),
  ),
  methods: (
    function("fn add(self, other: Rhs) -> Self::Output", "add"),
  ),
)

== Sub <trait-sub>

== Mul <trait-mul>

== Div <trait-div>

== Pow <trait-pow>

== Rem <trait-rem>

== Hash <trait-hash>

== Eq <trait-eq>

== Range <trait-range>

#pagebreak()
