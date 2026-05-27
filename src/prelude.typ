#import "lib/util.typ": secref

#let label-tree() = context {
  let headings = query(heading)

  let render(items, depth) = {
    let result = ()
    let i = 0
    while i < items.len() {
      let h = items.at(i)
      if h.level == depth {
        let children = ()
        let j = i + 1
        while j < items.len() and items.at(j).level > depth {
          children.push(items.at(j))
          j += 1
        }
        if children.len() > 0 {
          result.push(list.item[#secref(h.label) #render(children, depth + 1)])
        } else {
          result.push(list.item[#secref(h.label)])
        }
        i = j
      } else {
        i += 1
      }
    }
    list(..result)
  }

  render(headings, 1)
}

= Prelude <prelude>

== Sections <prelude-sections>

#label-tree()

== Motivation <prelude-motivation>

Scripting languages have long been celebrated for their dynamic, forgiving nature- a quality that served Silicon Valley's "move fast and break things" ideology well into the tech boom. But as codebases scaled into multi-million line projects, that forgiveness turned into a liability: the cognitive overhead of tracking types, contracts, and invariants was simply pushed from the language into the programmer's head: the wrong tool for the wrong job, if you may.

The most prominent offenders are JavaScript and Lua, each of which spawned a typed successor: #link("https://www.typescriptlang.org/", "TypeScript") and #link("https://luau.org/", "Luau") respectively- in an attempt to address this. On paper, that should be sufficient. In practice, neither language was designed with types in mind from the start, and this original flaw surfaces the deeper you go. The runtimes actively resist their own successors: JavaScript's prototype chain and Lua's metatables introduce dynamic behaviors that no static type system can fully tame, creating a permanent ceiling on how much safety and tooling these successors can realistically provide.

The loose semantics of these languages also carry a direct performance cost. Because so little can be assumed statically, just-in-time (JIT) compilers explode in complexity as they must work significantly harder; speculating about types, deoptimizing on mispredictions, and maintaining extremely complex machinery that a statically-typed language would never need, for little if not zero benefit. In the end, entropy is not even eliminated; it is simply deferred to runtime- which weaponizes it into a ticking time bomb.

Perhaps one of the more frustrating is the structural inability of these languages to improve quickly. Both JavaScript and Lua bear the weight of near-total backwards compatibility, which forces changes through slow, bureaucratic standardization processes if at all; as a large portion of improvements are simply incompatible. The consequences are not only theoretical:

#list(
  [*Luau:* The new type solver introduced in late 2024, remains highly unstable despite being an architecturally identical subset of TypeScript's own solver; design debt is inherited all the way back from Lua.],
  [*TypeScript:* Long-standing issues such as the unsoundness of function parameter bivariance, the absence of nominal typing, and the inability to express certain common patterns without resorting to #raw("any") have remained unresolved for years. Not for lack of awareness, but because fixing them would break the JavaScript ecosystem beneath them.],
)

What is needed is not a better patch on top of a dynamic foundation, but a language designed from the ground up with static guarantees, performance, and developer ergonomics as first-class design choices, not as afterthoughts or mandatory additions.

== Solution <prelude-solution>

It should be noted that this problem is non-trivial as any proper solution must strike a balance between safety and ergonomics- which by extension means either one must be sacrificed at some level.

#pagebreak()
