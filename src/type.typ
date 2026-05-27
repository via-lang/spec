#import "lib/util.typ": secref
#import "lib/generic.typ": const-generic, generic, render-generics, render-signature

#let type(id, name, desc, bnf, example, impls: (), generics: (), signature-fmt: none) = [
  #heading(level: 2)[#name] #label("type-" + id)

  #block(
    fill: luma(100%, 0%),
    inset: 8pt,
    width: 100%,
  )[
    #desc

    #raw(bnf, block: true)
    #render-signature("type", name, generics, fmt: signature-fmt)
    #render-generics(generics)

    #if impls.len() > 0 [
      *Implements*
      #table(
        columns: (auto, 1fr),
        stroke: none,
        inset: (x: 6pt, y: 4pt),
        fill: (_, row) => if calc.odd(row) { luma(100%, 0%) } else { none },
        [*Trait*], [*Implementations*],
        ..impls
          .map(impl => (
            secref(label("trait-" + lower(impl.name))),
            stack(
              dir: ttb,
              spacing: 3pt,
              ..impl.impls.map(i => raw(i, block: false, lang: "rs")),
            ),
          ))
          .flatten(),
      )
    ]
    \
    *Examples*
    #example
  ]
]

= Types <type>

\
```
type ::=
  | type_never
  | type_unit
  | type_bool
  | type_int
  | type_float
  | type_string
  | type_array
  | type_vector
  | type_map
  | type_option
  | type_union
  | type_tot
  | type_agt
  | ( '(' type ')' )?
```

#type(
  "never",
  "Never",
  [Represents a \"value\" that is guaranteed to never be reached by control flow. Most commonly used for constraining control paths. The only way to produce this type is to wrap the #secref(label("builtin-panic")) function. This type also cannot be used in contexts outside of control flow.],
  "type_never ::= '!'",
  ```rs
    fn assert(v: bool) -> !? {
        match v {
            true => (),
            false => panic("assertion failed!")
        }
    }
  ```,
  signature-fmt: "!",
)

#type(
  "unit",
  "Unit",
  "Represents the absence of a value.",
  "type_unit ::= '()'",
  ```rs
    type Unit = ();
  ```,
  signature-fmt: "()",
)

#type(
  "bool",
  "Boolean",
  "boolean",
  "type_bool ::= 'true' | 'false'",
  ```rs
  ```,
  impls: (
    (name: "Defined", impls: ("impl Defined",)),
  ),
  signature-fmt: "bool",
)

#type(
  "int",
  "Integer",
  "integer",
  "type_int ::= 'int'",
  ```rs
  ```,
  impls: (
    (name: "Defined", impls: ("impl Defined",)),
    (name: "Clone", impls: ("impl Clone",)),
    (
      name: "Add",
      impls: (
        "impl Add<Output = int>",
        "impl Add<float, Output = float>",
      ),
    ),
    (
      name: "Sub",
      impls: (
        "impl Sub<Output = int>",
        "impl Sub<float, Output = float>",
      ),
    ),
    (
      name: "Mul",
      impls: (
        "impl Mul<Output = int>",
        "impl Mul<float, Output = float>",
      ),
    ),
    (
      name: "Div",
      impls: (
        "impl Div<Output = float>",
        "impl Div<float, Output = float>",
      ),
    ),
  ),
  signature-fmt: "int",
)

== Float <type-float>

== String <type-string>

#type(
  "array",
  "Array",
  "array",
  "type_array ::= '[' type ';' expr_int ']'",
  ```rs
    type
  ```,
  impls: (
    (name: "Defined", impls: ("impl Defined",)),
  ),
  generics: (
    generic("T", bounds: ("Defined",)),
    const-generic("N", "int"),
  ),
  signature-fmt: "[%0; %1]",
)

#type(
  "vector",
  "Vector",
  "vector",
  "type_vector ::= '[' type ']'",
  ```rs
    type DrawQueue = [dyn Drawable];
  ```,
  impls: (
    (name: "Defined", impls: ("impl Defined",)),
  ),
  generics: (
    generic("T"),
  ),
  signature-fmt: "[%0]",
)

#type(
  "map",
  "Map",
  "map",
  "type_map ::= '#{' type ':' type '}'",
  ```rs
    type IntMap<T> = { int: T };
  ```,
  impls: (
    (name: "Defined", impls: ("impl Defined",)),
  ),
  generics: (
    generic("K", bounds: ("Hash", "Eq")),
    generic("V"),
  ),
  signature-fmt: "#{ %0: %1 }",
)

#type(
  "option",
  "Option",
  [Option types are a way to form a tagged union between a type that implements #secref(label("trait-defined")) and the #secref(label("type-unit")) type.],
  "type_option ::= type '?'",
  ```rs
    fn tostring(v: int?) -> string {
        match v {
            <int>(int) => int.to_string(),
            <()> => "()"
        }
    }
  ```,
  impls: (
    (name: "Defined", impls: ("impl Defined",)),
  ),
  generics: (
    generic("T", bounds: ("Defined",)),
  ),
  signature-fmt: "%0?",
)

#type(
  "union",
  "Union",
  "Union types are a way to form a tagged union between two constituent types.",
  "type_union ::= type '|' type",
  ```rs
    type Number = int | float;
    type NumOrBool = int | float | bool;
  ```,
  impls: (
    (name: "Defined", impls: ("impl Defined",)),
  ),
  generics: (
    generic("T", bounds: ("Defined",)),
    generic("U", bounds: ("Defined",)),
  ),
  signature-fmt: "%0 | %1",
)

#type(
  "tot",
  "Trait Object Type",
  [Trait objects are a way to bound a truly anonymous, unknowable type - not to be confused with #secref(label("type-agt")) - they are completely dynamic (as implied by the `dyn` keyword) and feature runtime overhead, but can be used practically anywhere unlike AGTs.],
  "type_tot ::= 'dyn' trait_bounds",
  ```rs
    trait Draw {
      fn draw(&self);
    }

    struct DrawContext {
      queue: [dyn Draw], // Illegal with AGTs
    }
  ```,
  signature-fmt: "dyn <Bounds...>",
)

#type(
  "agt",
  "Anonymous Generic Type",
  [Anonymous generics - or simply #strong("AGT")s - let you specify the bounds of an anonymous, specialized generic directly on the type. These types can only be used in contexts where types can be generalized, most commonly in #secref(label("functions")).],
  "type_agt ::= 'impl' trait_bounds",
  ```rs
    fn draw(obj: impl Drawable) {
      obj.draw();
    }

    // Equivalent to:
    fn draw<T: Drawable>(obj: T) {
      obj.draw();
    }
  ```,
  signature-fmt: "impl <Bounds...>",
)

#pagebreak()
