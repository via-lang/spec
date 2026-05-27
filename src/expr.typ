#import "lib/util.typ"

#let expr(name, type, desc, bnf, example) = [
  #heading(level: 2)[#name] #label("expr-" + lower(name))
  #block(
    fill: luma(100%, 0%),
    inset: 8pt,
    width: 100%,
  )[
    #desc
    #raw(bnf, block: true)

    *Type* #util.secref(label("type-" + type))
    \
    *Examples*
    #example
  ]
]

= Expressions <expr>

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
  | expr_range
  | expr_prange
```

#expr(
  "Unit",
  "unit",
  [Represents the absence of any value.],
  "expr_unit ::= ()",
  ```rs
    let unit = ();
  ```,
)

#expr(
  "Boolean",
  "bool",
  [Represents a binary truth value.],
  "expr_bool ::= 'true' | 'false'",
  ```rs
    let yes = true;
    let no = false;
  ```,
)

#expr(
  "Integer",
  "int",
  [Represents a signed 64-bit integer literal. Multiple notations such as decimal, hexadecimal, and binary are supported through their respective delimiters. The literals can optionally be split for the sake of easier reading by inserting an underscore ('\_') between any two digits.],
  "expr_int ::= [0-9]+ | '0x' [0-9A-Fa-f]+ | '0b' [01]+",
  ```rs
    let base10 = 1_234_567_890;
    let base16 = 0x123_A_BCDEF;
    let base2 = 0b1100_1100;
  ```,
)

#expr(
  "Float",
  "float",
  [Represents a double precision IEEE-754 standard floating point number.],
  "expr_float ::= [0-9]+ '.' [0-9]+",
  ```rs
    let num = 1.0;
    let pi = 3.14159;
  ```,
)

#expr(
  "String",
  "string",
  [Represents an unbound sequence of UTF-8 codepoints.],
  "expr_string ::= 'f'? '\"' ([^\"\\\n] | '\\' ('\"' | '\\' | 'n' | 't') | '{' expr '}')* '\"'",
  ```rs
    let string = "abcdef123456";
    let format = f"hi {string}";
  ```,
)

#expr(
  "Array",
  "array",
  [Represents a fixed-size array of generic elements. All elements must be of the same type.],
  "expr_array ::= '[' (expr,)* expr? ']'",
  ```rs
    let array = [1, 2, 3];
  ```,
)

#expr(
  "Vector",
  "vector",
  [Represents a dynamically-sized array of generic elements. All elements must be of the same type. Must be disambiguated from #util.secref(label("expr-array")) via type inference or explicit cast.],
  "expr_vector ::= '[' (expr,)* expr? ']'",
  ```rs
    let vector = [1, 2, 3] as [_];
  ```,
)

#expr(
  "Map",
  "map",
  [Represents a hash map. All key-value pairs must be of the same respective types.],
  "expr_map ::= '#{' ( expr ':' ,)* '}'",
  ```rs
    let map = #{
        a: 10,
        b: 20
    };
  ```,
)

#expr(
  "Range",
  "range",
  [Represents a uniformly distributed range of elements bound on either side.],
  "expr_range ::= expr '..' '='? expr",
  ```rs
    let range = 1..6;
    let inclusive = 1..=6;
  ```,
)

#expr(
  "Partial Range",
  "prange",
  [Represents a uniformly distributed range of elements unbound on one side.],
  "expr_prange ::=
  | ( '..' '='? expr )
  | ( expr '..' )
  ",
  ```rs
    let partial_left = ..=15;
    let partial_right = 15..;
  ```,
)

#pagebreak()
