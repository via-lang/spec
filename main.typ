#import "@preview/note-me:0.6.0": *

#set page(height: auto)
#set heading(numbering: "1.")

#let secref(lbl) = context {
  let results = query(lbl)
  if results.len() == 0 {
    text(fill: red)[⚠ missing label: #str(lbl)]
  } else {
    let h = results.first()
    let num = counter(heading).at(h.location()).map(str).join(".")
    link(lbl, text(fill: blue.darken(20%), underline(
      stroke: (paint: blue.darken(20%), dash: "dotted"),
      [#sym.section #num #sym.dot #h.body],
    )))
  }
}

#let expr(name, type, desc, bnf, example) = [
  #heading(level: 2)[#name] #label("expr-" + lower(name))
  #block(
    fill: luma(100%, 0%),
    inset: 8pt,
    width: 100%,
  )[
    #desc
    #raw(bnf, block: true)

    *Type* #secref(label("type-" + type))
    \
    *Examples*
    #example
  ]
]

#let type(name, desc, bnf, example, impls: (), generics: ()) = [
  #let generics-str = if generics.len() > 0 {
    let parts = generics.map(g => {
      if g.bounds.len() > 0 {
        g.name + ": " + g.bounds.join(" + ")
      } else {
        g.name
      }
    })
    "<" + parts.join(", ") + ">"
  } else {
    ""
  }

  #heading(level: 2)[#name#raw(generics-str)] #label("type-" + lower(name))

  #block(
    fill: luma(100%, 0%),
    inset: 8pt,
    width: 100%,
  )[
    #desc
    #raw(bnf, block: true)

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

#align(center)[
  #text(size: 32pt, weight: "bold")[The Via Programming Language] \
  #v(0.5em)
  #text(size: 14pt)[O. Ç. (xnlogical)] \
  #text(size: 12pt, style: "italic")[\<xnlogical\@gmail.com>] \
  #v(1em)
  #text(size: 11pt)[Version 1.0 #sym.dot May 2026]
]

= Prelude

== Motivation

Scripting languages have long been celebrated for their dynamic, forgiving nature- a quality that served Silicon Valley's "move fast and break things" ideology well into the tech boom. But as codebases scaled into multi-million line projects, that forgiveness turned into a liability: the cognitive overhead of tracking types, contracts, and invariants was simply pushed from the language into the programmer's head.

The most prominent offenders are JavaScript and Lua, each of which spawned a typed successor: #link("https://www.typescriptlang.org/", "TypeScript") and #link("https://luau.org/", "Luau") respectively- in an attempt to address this. On paper, that should be sufficient. In practice, neither language was designed with types in mind from the start, and this original flaw surfaces the deeper you go. The runtimes actively resist their own successors: JavaScript's prototype chain and Lua's metatables introduce dynamic behaviors that no static type system can fully tame, creating a permanent ceiling on how much safety and tooling these successors can realistically provide.

The loose semantics of these languages also carry a direct performance cost. Because so little can be assumed statically, just-in-time (JIT) compilers explode in complexity as they must work significantly harder; speculating about types, deoptimizing on mispredictions, and maintaining extremely complex machinery that a statically-typed language would never need, for little if not zero benefit. In the end, entropy is not even eliminated; it is simply deferred to runtime- which weaponizes it into a ticking time bomb, which in turn makes this a fundamental flaw of dynamic languages.

Perhaps one of the more frustrating is the structural inability of these languages to improve quickly. Both JavaScript and Lua bear the weight of near-total backwards compatibility, which forces changes through slow, bureaucratic standardization processes if at all; as a large portion of improvements are simply incompatible. The consequences are not only theoretical:

#list(
  [*Luau:* The new type solver introduced in late 2024, remains highly unstable despite being an architecturally identical subset of TypeScript's own solver; design debt is inherited all the way back from Lua.],
  [*TypeScript:* Long-standing issues such as the unsoundness of function parameter bivariance, the absence of nominal typing, and the inability to express certain common patterns without resorting to #raw("any") have remained unresolved for years. Not for lack of awareness, but because fixing them would break the JavaScript ecosystem beneath them.],
)

What is needed is not a better patch on top of a dynamic foundation, but a language designed from the ground up with static guarantees, performance, and developer ergonomics as first-class design choices, not as afterthoughts or mandatory additions.

== Solution

It should be noted that this problem is non-trivial as any proper solution must strike a balance between safety and ergonomics- which by extension means either one must be sacrificed at some level.

#pagebreak()

= Expressions

\
```
expr ::=
  | expr_unit
  | expr_bool
  | expr_int
  | expr_float
  | expr_string
  | expr_array
  | expr_vector
  | expr_map
```

#expr(
  "Unit",
  "unit",
  "Represents the absence of any value.",
  "expr_unit ::= ()",
  ```rs
    let unit = ();
  ```,
)

#expr(
  "Boolean",
  "bool",
  "Represents a binary true or false value.",
  "expr_bool ::= 'true' | 'false'",
  ```rs
    let yes = true;
    let no = false;
  ```,
)

#expr(
  "Integer",
  "int",
  "Represents a signed 64-bit integer literal. Multiple notations such as decimal, hexadecimal, and binary are supported.",
  "expr_int ::= [0-9]+ | '0x' [0-9A-Fa-f]+ | '0b' [01]+",
  ```rs
    let base10 = 1234567890;
    let base16 = 0x123ABCDEF;
    let base2 = 0b11001100;
  ```,
)

#expr(
  "Float",
  "float",
  "Represents a double precision IEEE-754 standard floating point number.",
  "expr_float ::= [0-9]+ '.' [0-9]+",
  ```rs
    let num = 1.0;
    let pi = 3.14159;
  ```,
)

#expr(
  "String",
  "string",
  "Represents an unbound sequence of UTF-8 codepoints.",
  "expr_string ::= 'f'? '\"' ([^\"\\\n] | '\\' ('\"' | '\\' | 'n' | 't') | '{' expr '}')* '\"'",
  ```rs
    let string = "abcdef123456";
    let format = f"hi {string}";
  ```,
)

#expr(
  "Array",
  "array",
  "Represents a fixed-size array of generic elements. All elements must be of the same type.",
  "expr_array ::= '[' (expr,)* expr? ']'",
  ```rs
    let array = [1, 2, 3];
  ```,
)

#expr(
  "Vector",
  "vector",
  [Represents a dynamically-sized array of generic elements. All elements must be of the same type. Must be disambiguated from #secref(label("expr-array")) via type inference or explicit cast.],
  "expr_vector ::= '[' (expr,)* expr? ']'",
  ```rs
    let vector = [1, 2, 3] as [_];
  ```,
)

#expr(
  "Map",
  "map",
  "Represents a hash map. All key-value pairs must be of the same respective types.",
  "expr_map ::= '{' ( expr ':' ,)* '}'",
  ```rs
    let map = {
        a: 10,
        b: 20
    };
  ```,
)

#pagebreak()

= Types

\
```
type ::=
    | type_unit
```

#type(
  "Unit",
  "Represents the absence of a value.",
  "type_unit ::= '()'",
  ```rs
    type Unit = ();
  ```,
  impls: (
    (
      name: "Add",
      impls: (
        "impl Add<Output = int>",
        "impl Add<Output = float>",
      ),
    ),
    (
      name: "Clone",
      impls: ("impl Clone",),
    ),
  ),
)

== Boolean <type-bool>

== Integer <type-int>

== Float <type-float>

== String <type-string>

== Array <type-array>

== Vector <type-vector>

== Map <type-map>

#pagebreak()

= Traits

== Add <trait-add>

== Clone <trait-clone>
