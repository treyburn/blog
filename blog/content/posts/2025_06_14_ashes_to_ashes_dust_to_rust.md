+++
date = '2025-06-14' # date of publication
author = 'Travis Reyburn'
title = 'a go developer learns rust' # official title of the post
displayTitle = 'Ashes to Ashes Dust to Rust' # display title in content
displayLanguage = 'rust'
subtitle = 'the beginnings of my journey to properly learn rust' # subtitle used for display and content
tagline = "don't forget to take to take yer anti-oxidants, kids" # note on the sidebar
description = 'a beginners journey of learning the rust programming language' # seo description? unclear of usecase
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ["rust", "programming", "learning rust", "programming in rust", "rustlang", "rust programming language", "cargo"] # seo keywords
+++
## on the requirements of learning
many a software engineer has complained that the profession is an endless treadmill of learning. they're not wrong -- but i don't see this as drudgery. this is partly why i got into the profession in the first place. things move fast -- there's always more to learn! i rather like that lack of stagnation[^1].

i do understand why some consider it a drag. unlike the typical 9-5 -- there's an insidious amount of background learning that you must maintain. a long time ago i tricked my brain into engaging with this by replacing my mindless reddit scrolling with .... more reddit scrolling but this time i un-subbed from every subreddit that wasn't productive to my learning, personal growth, or niche hobby interests[^2].

after a while i started to outgrow reddit and instead discovered hacker news. while there is much i loathe about the right-leaning vc bro culture of the site -- it's where many knowledge workers gather to discuss emerging technologies. so, it suffices for the time being[^3]. 

eventually i want to disengage with the site and move to a curated rss feed of small, but worthwhile technical blogs. 

one day, maybe[^4].

really the biggest drawback of the endless learning this profession requires is that it ends up superseding other learnings. i've married into the french culture -- but i don't speak the language. i *want* to learn french -- but the amount of effort which must be sincerely invested exceeds the bandwidth of learning i have available after what is also required for work. until i achieve some level of financial independence, it feels impossible to prioritize.

one day, definitely[^5].

## let's shake off the rust
it's been a minute since i've learned a new language. i suppose you could consider typescript to be the language i've learned most recently; although i started learning it ages ago. i feel somewhat comfortable with it -- although i must admit i rather loathe it. the syntax of the language, the runtime, the ecosystem, the tooling -- none of it feels as ergonomic and useful as go. but it's the lingua franca of the internet -- so we must persist. at least i get paid to write it[^6].

i've wanted to learn rust for a long time. but i've never been able to justify the mental expenditure. there's already so much i must learn to stay capable and competitive in work. however, rust is gaining traction within the industry and at my company. i am working increasingly in performance-sensitive areas of our code base. the timing feels right.

## crabs in a bucket
why do i want to learn rust? honestly, it just seems like an interesting language. i started to learn go because i was interested in learning a lower level language[^7]. i still have a curiosity to learn more -- to get closer to the machine. the typesystem and the compiler guarantees are intriguing to me. and it seems to be one of the few languages where the tooling is on the same level as go. the idea of being able to write my own drone firmware is one of those crazy ideas that i just can't shake loose of.

i also have a suspicion that it's going to be an insanely good language to use with ai. the compiler guarantees for correctness -- and the quality of the compiler errors -- should be sufficient guardrails for the hardest to debug errors that ai tends to produce. i think the conjunction of compiler safety and tests on the business logic should let me vibe code some shockingly good software.

or so i'm hoping. we'll see.

anyways, let's get started. my first step was to go check out [the book](https://doc.rust-lang.org/book/) -- but as it turns out, there's an even [newer book](https://rust-book.cs.brown.edu/). so i'm gonna check that out.

first we download rust via:
```shell
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

personally, i hate this method of installation. curling a shell script and piping it to `sh`? would could possibly go wrong with that? 👼

but it worked -- sorta -- i had to modify my `.zshrc` since apparently it wasn't picking up the `.zshenv` that the script made? idk.

anyways -- here we go!
```rust
# main.rs

fn main() {
    println!("wheres waldo?");
}
```

```shell
rustc ./main.rs && ./main
> wheres waldo?
```

have you ever seen a `hello world` that's so *blazingly fast* and *fearlessly concurrent* and *memory safe*? me neither 😎

## join the cargo cult
my understanding is that you don't really call `rustc` directly much. `cargo` is the real star of the show and that's where [the book](https://rust-book.cs.brown.edu/ch01-03-hello-cargo.html) heads next.

let's run the following:
```shell
cargo new learning
```

interestingly -- this creates a new directory of `learning` and inits a project in there including a new git repo. i don't actually want that and i want to stay in my current dir which already includes a git repo. turns what i'm looking for is actually for is `cargo init`.

now i can run my program with:
```shell
cargo run
> wheres waldo?
```

ok! now that we've got a trivial setup - lets make something a bit more fun. can you guess it?

## the guessing game
now we've updated our main to the following:

```rust
use std::io;

fn main() {
    println!("guess the number");
    
    println!("your input pls:");
    
    let mut guess = String::new();
    
    io::stdin().read_line(&mut guess).unwrap();
    
    println!("you guessed: {guess}");
}
```

there's actually some pretty neat learnings in just this simple example. `let mut guess = String::new();` this defines the string as mutable. if you remove the `mut` and just `let guess = String::new();` you'll get a compiler error! it's a bit counter intuitive -- as we call `.read_line(&mut guess)` -- but this is a neat piece! you can pass around a mutable pointer, but all the call site you can declare if you are actually mutating or just reading the value. this is a key piece of borrow logic! i think it also makes for a really clear api. i always try to do similar in golang regarding points vs references as function arguments -- but it's not always doable.

something that's still not totally clear to me is why there is `let thing = String::new();` vs `let mut thing = String::new();`. shouldn't the former be equivalent to a const? Another interesting tidbit I've learned hacking around with this:

```rust
# theres no way you can sert any value here
const FOO: String = String::new(); 

# heres what you need instead
const BAR: &str = "this is a const string";
```

rust has two types for what i would think of as a `string`. a `String` in rust is a growable buffer. this makes sense -- in most languages strings are actually byte arrays. go makes this a bit more confusing by having strings represented as `[]byte`. whne you access `someString[index]`, you get a byte. but when you iterate over a string, you get a `rune` which is an alias of an `int32` and represents a unicode character (which is also what you get in python). personally, i wish they would have represented strings as `[]rune` so `someString[index]` would just return a rune.

in practice, a `String` in rust is like a `bytes.Buffer` in go but with `string` methods wrapped around it.

the other kind of string is a `&str`. this is a pointer to an immutable string. hence why `const` works with it but not `String`.

another unusual bit that this quickly introduces us to is the `Result` type. `io::stdin().read_line(&mut guess)` returns a `Result` which is either `T` or an `error` (for the uninitiated).

i'm still on the fence about whether I like this better than go's error handling or not. on one hand - you get methods like `.unwrap()` (but what happens if it's an error? turn's out -- it `panics`. that feels like a footgun).

but if you want actual error handling you need to do the following:
```rust
let res = io::stdin().readline(&mut guess)
match res {
    Ok(x) => println!("ok: {x}"),
    Err(e) => println!("error: {e}"),
}
```

is that really any more legible than go's error handling?
```go
res, err := reader.ReadString('\n')
if err != nil {
	fmt.Println("error: ", err)
}
```

the advantage of the rust approach is that the compiler *forces* you to handle the error. go is happy to let you ignore it. in practice, this has almost never been an issue for me.

sometimes it's even kinda nice. for instance, you can:
```go
defer funcThatMightErrorButIDontCare()
```

here you have a nice way to defer a function that could be doing something like release a resource. if it fails to close, for whatever reason, it'll eventually get garbage collected anyways. there's times in practice that we truly do not care about an error and go lets you do that. is that -- dare i say -- more expressive than rust? maybe not -- maybe rust has a `result.throw_away()`. we'll find out.

and what happens if you want to do more complex error handling? it's not the prettiest in go -- but i'm not totally blown away by the synatx here either. either way -- i'll take the explicit error handling of both go and rust of crap like exceptions.

```javascript
try { thatBullshit() } catch { theseHands() }
```

anybody who tells you go needs `try/catch` semantics needs to `alt+f4`.

another piece i haven't seen addressed with rust's `Result` type -- is that sometimes you want to return the `result, err` and both can have meaning.

if i'm paginating over something in go and encounter an error -- i can return `int, err`. that `err` value is critical in indicating tat something didn't process correctly -- but the `int` value might represent the current location of pagination and be useful for a retry mechanism. i'm not sure how rust handles that (maybe by creating a custom error type?) but it does feel like a shortcoming of the `Result` enum approach where it *must* be either `int` or `err`.

as a side note -- i'll say that i'm pretty blown away by how education the rust compiler is so far. i've actually stopped googling questions and insteam am just writing broken code to see what the compiler tells me about it. 

also -- the stdlib's built-in documentation is super rich and well written and the `rust rover` ide renders it as markdown. i've not seen another language/ide do this -- including go which i feel also has very strong documentation. so kudos to the rust team and jetbrains.

and there's more! the rust compiler seems to have a built-in linter/static analysis tool (a la `go vet` but more powerful) and there are even directives allowing you to declaratively ignore things at a given location -- or entirely suppress it. neat!

ok -- moving on with enormous learnings from our trivial examples.

let's use more `cargo` features by bringing in a dep to generate random numbers[^8].

next we run:
```shell
cargo add rand
```

and it -- pulls in 12 deps! holy cow. this feels a bit shocking coming from the go ecosystem where it's a point of pride to have large libraries implemented in nothing but the stdlib. zero dependencies is something to strive for! but not in rust -- this is definitely an area where i worry the ecosystem will increasingly become like javascript. *shivers*

anyways -- we'll get over the culture shock[^9]. i will say though -- it's pretty neat how rust will parallelize compiling based on crate.

now we can add in random number generation with:
```rust
let secret_number = rand::rng().random_range(1..=100);
```

writing this simple line leads to several cool learnings. *the book* is apparently out of date already. they wanted me to use `rand::thread_rng().gen_range()` -- but both `thread_rng()` and `gen_range()` are deprecated. the compiler quickly told me that and provided the new functions to use. apparently there is a directive (`#[deprecated(since = "0.9.0", note = "Renamed to `rng`")]`) which provides helpful info and is gated to version info. this is really cool! i love all the built-in documentation here.

also -- i thought the range syntax of `1..=100` was pretty neat. sometimes it's hard to know if `1..100` means 1 through 100 or 1 up to 100. this removes that ambiguity entirely!

more interesting things i've learned -- `cargo` has a `fix` command which can fix broken code, clean up lint warnings, etc. it's even git state-aware and gives a nice warning to commit your code before running it. that's amazing!

another neat piece of rust that go won't handle. you can re-use a named variable by calling `let $VARIABLE` again even as an entire different type!

for example:
```rust
let mut guess = String::new();

io::stdin()
    .read_line(&mut guess)
    .expect("Failed to read line");

# go wouldn't allow this due to type differences
let guess: u32 = guess.trim().parse().expect("Please type a number!");
```

i guess now i'm wondering -- what happens to the `String` version of `guess`? rust doesn't have garbage collection -- so where did it go?! we'll figure that out in due time.

so now we have our whole program:
```rust
use std::cmp::Ordering;
use std::io;
use rand::Rng;

fn main() {
    println!("guess the number!");
    
    let secret_number = rand::rng().random_range(1..=100);
    
    println!("the secret number is: {secret_number}");
    
    loop {
        println!("your input pls:");

        let mut guess = String::new();

        io::stdin().read_line(&mut guess).expect("failed to read line");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            },
        }
    }

}
```

closing thoughts. all the `;` feel so unnecessary. the compiler knows where they're missing -- so it's smart enough to figure things out without them. this feels like an anachronism that snuck into the language. also i don't love the hidden returns in rust -- that's going to take some getting used to and frankly feels like it intentionally makes code harder to read at the benefit of .... like one weird and highly opinionated person that probably should have been ignored and left to die on this particular hill.

[^1]: but more power to those in a comfy static gig! my adhd brain is simply incapable of it. ouroboros must grow -- lest it devours itself.
[^2]: i dont think i could possibly rage harder against the endless doom-scrolling these platforms offer. just say 'no', kids.
[^3]: have you heard of our lord and savior: common lisp?
[^4]: but i'll have to create an rss curation product first. 🤡
[^5]: tous jour, je comprend un petit pue plus.
[^6]: still unclear if this is actually a benefit.
[^7]: coming from python and no cs background -- basically everything is lower level.
[^8]: gotta say -- it's a little shocking this isn't part of the stdlib.
[^9]: and horrific supply chain attack surface.