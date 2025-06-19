+++
date = '2025-06-15' # date of publication
author = 'Travis Reyburn'
title = 'Continuing my learnings with the rust book' # official title of the post
displayTitle = 'Thanks for All the Turbofish' # display title in content
displayLanguage = 'rust'
subtitle = 'my continued ramblings through the rust book' # subtitle used for display and content
tagline = 'never eat raw turbofish in a landlocked lang' # note on the sidebar
description = 'continuing my journey of learning rust -- raves, rants, and annoyances galore' # seo description? unclear of usecase
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ["rust", "programming", "learning rust", "programming in rust", "rustlang", "rust programming language", "cargo"] # seo keywords
+++
## the learning continues
as i continue through [the book](https://rust-book.cs.brown.edu/ch03-01-variables-and-mutability.html), it touches on a few items i explored yesterday. namely, `const` vs `let`. a new items which i have learned is that `const` can be used as a global -- but `let` cannot. the compiler helpfully pointed to me that i can, however, use `static`. what is `static` and how does it differ from `const`? unclear! but we'll get there eventually.

for now i'd like to move on and let *the book* guide me.

it proceeds to talk about data types in rust -- which i know from previous exposure to rust is a huge part of the language. algebraic types are what make rust so compelling -- beyond the memory safety, pedantically correct yet stellarly helpful compiler, and god tier cli tooling. seriously -- i *cannot* get over how amazing `cargo fix --allow-dirty -- broken-code` is.

anyways, we come back to a line we wrote yesterday:
```rust
let guess: u32 = "42".parse().expect("Not a number!");
```

i know the example just wants to talk about basic types and type declarations -- but i made me curious how `parse()` works. i swapped `guess: u32` to `guess: i64` expecting a compiler error -- but i did not get one! i figured maybe that's because `i64` is a superset of `u32`. perhaps a float like `f32` will error out ... but it does not!

so what is going on here? floats and ints are quite different. how does this work?

so i clicked into the function definition of `parse()` -- and discover that it can parse anything which implements the `FromStr` trait. what's a trait? my understanding is that it's like an `interface` in Go but more powerful.

## so long focus
i also noticed this peculiar note:
```text
As such, parse is one of the few times you'll see the syntax affectionately known as the 'turbofish': ::<>(). 
This helps the inference algorithm understand specifically which type you're trying to parse into.
```

turbofish! i can't help but giggle. forget `p = np`, naming is the hardest unsolved problem in cs.

so what the heck is turbo fish? well from what i can tell it's an escape hatch to tell the compiler a type when the generics are just too complex for eve it to understand.

another piece that really stood out to me is the `impl trait` mechanism. this has been a big gripe of go for me. i rather dislike duck typing -- just let me declare that something implements an interface. the compile time assertions, a la `var _ Foo = (*fooImpl)(nil)`, are gross.

it also seems that you can derive trait implementations with the `#[derive(Trait)]` directive? unclear. i also tried to find where integer types implement `FromStr` -- and i think i found it hidden in a gnarly `marcro_rules!` ... macro? where it appears to use the string contents to determine if it was signed vs unsigned and an int vs a float? honestly it's rather difficult to read. i suspect this is where i will find my biggest grievances with rust. with go, i can typically click into a function's definition and immediately understand what it's doing. whether its from the stdlib, a 3rd party dep, code a coworker wrote, or code i wrote in the past. it's all clean and straight to the point and generally looks the same regardless of who wrote it. it honestly feels like a superpower[^1] when i can just click through some function definitions and immediately understand a weird bug we're seeing. with rust -- i think this superpower will be gone. it feels like im back in python-land where meta-programming reigns supreme and your only hope is reading docs[^2].

## digression digested
ok - let's get back on topic and try to actually make some progress.

neat note from reading on types -- rust ships with an `i128` type. yay! i've never needed this in practice in go[^3] -- but it's nice that it ships as a core part of the language which must be implemented on all target platforms and architectures.

oh my! rust has real tuples! and tuple destructuring!

```rust
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup;

    println!("The value of y is: {y}");
}
```

## array vs vec
ah -- and there's arrays (fixed length and on the stack) vs vectors (growable/shrinkable and on the heap) vectors are the "same" as slices in go. makes sense!
```rust
fn main() {
    // it can be re-sized, appended on, trimmed, etc 
    let this_is_a_slice = vec![1, 2, 3];
    
    // it cannot be re-sized, appended on, etc
    let this_is_an_array = [1, 2, 3];
}
```

## #&*%$! returns
idiomatic rust uses implicit returns in expressions.

this is a big of a bummer for me. this feels like yet another sacrifice of legibility for *"expressiveness"* -- or pointless terseness as i'd declare it.
```rust
fn five() -> i32 {
    5
}
```

would `return 5` really be that hard to type? having to spot all the locations where a value might return is going to be a bit more challenging when initially reading a function in code review. i don't see any point in being implicit like this. developer time reading code is **so** much more expensive than the time spent typing out `return`.

maybe this is some nuclear hot-take -- but code is infinitely easier to write than read and we should not optimize for improved ergonomics of writing over reading.

honestly -- im increasingly aggravated by this. i *really* want to love rust -- but decisions like this just feel so annoying. and they accumulate as you use and learn the language. i suspect i would rather dislike the person who argued passionately for this particular language design choice.

that's not to say you *must* use implicit returns. in fact -- rust does give you the means to enforce this via clippy:

```rust
#![deny(clippy::implicit_return)]
#![allow(clippy::needless_return)]
```

it just feels so pointless to have to do this. and it'll cause the kind of needless style debates that plague javascript/cpp/python/etc -- the same pointless arguments that i felt so refreshingly liberated from after using `go fmt`. ugh.

moving on.

## thrown for a loop
loops are a bit strange in rust. `loop`, `while`, and `for` are all loop keywords. `loop` vs `while` feel redundant to me -- although i get the subtle distinction. i guess it's better than `for` being the only loop keyword like in go. `for { ... }` always felt a bit alien.

loops can also return values -- but seeing this is just making me wish we had ... explicit returns!

```rust
fn main() {
    let mut counter = 0;

    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };

    println!("The result is {result}");
}
```

`break counter * 2;` -- seriously? my kingdom for a fucking `return`!

named loops also exist in rust -- as they do in go. although quite honestly, it's pretty rare that i've used them in go.
```rust
fn main() {
    let mut x = 0;
    'a: loop {
        x += 1;
        'b: loop {
            if x > 10 {
                continue 'a;
            } else {
                break 'b;
            }      
        }
        break;       
    }
}
```

the `'name` syntax is a bit interesting. i think this has to do with lifetimes? at least it looks like the lifetime syntax -- but we'll get to that later.

## wrapping up
i think that's enough for this blog post. i've got some turbofish to cook.

[^1]: this + the dead simple (to write) concurrency model + god tier cli tooling is what makes me love go. the advantage of go forcing boilerplate on the developer is that you can *just read* what code is doing and understand. a prioritization of read-perf over write-perf is how i like it.
[^2]: and you better hope those docs ain't lying!
[^3]: not true -- one time i realized we started to overflow an `int64` because some brainiac wanted to use bit-shifting over `iota` for an enum that clearly was bound to grow massive (discrete product interactions). thanks mr "go developer and database wrangler". always love when greybeards with the *weirdest* language hot-takes get to throw pragmatism out the window -- yet it is *you* who must yield to *them* -- otherwise *you* are somehow the uncooperative one. whatever.