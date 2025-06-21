+++
date = '2025-06-19' # date of publication
author = 'Travis Reyburn'
title = 'Pwnership' # official title of the post
displayTitle = 'Pwnership' # display title in content
displayLanguage = 'rust'
subtitle = "just tell me if you need to borrow something, alright?" # subtitle used for display and content
tagline = "you can borrow a piano but you can't turbo fish" # note on the sidebar
description = "a beginner's shallow dive into the deep end of rust" # seo description? unclear of usecase
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ["rust", "programming", "learning rust", "programming in rust", "rustlang", "rust programming language", "cargo"] # seo keywords
+++
## undefined behavior is like a box of chocolates
ownership semantics are the core of what makes rust such a uniquely powerful language. is how rust can be memory managed without you having to declare `free()` everywhere. 

it's why rust is memory safe!

ok -- but what even is memory safety? to understand that -- we must venture into the unknown. *undefined behavior*. compilers provide a set of guarantees -- this is called defined behavior.

but what does that even mean?

if we think about what a compiler does -- its essentially creating a program that spits out cpu instructions. the cpu doesn't necessarily know what's valid or not. it just receives instructions and executes them.

if you tell your program to operate on some bool value -- you send instructions to your cpu and you're expecting it to return a byte that represents either `true` or `false`. but if your program is incorrect with it's handling of memory -- that byte might represent something totally different! then what happens with your program? presumably *something* still happens. maybe it crashes, maybe it continues to run in some unexpected way. that's undefined behavior.

so when rust makes claims about its strong memory safety guarantees -- it's actually claiming to radically reduce the surface area of undefined behavior.

## hey neighbor, can i borrow this int?
and how does rust make those guarantees? a huge piece of this is it does that by handling the manual memory management for you.

> wait -- isn't rust a language with manual memory management?

no! that is to say -- rust has no garbage collection -- but there's no manual memory management[^1]. the compiler does all the allocations/deallocations for you! this surprised me too -- when i began my learning journey, i was expecting to have to call `free()` all over the place.

instead of something like ref counting -- rust defines an `ownership` model. memory can only have 1 owner. ownership can also be transferred. but once the owner goes out of scope -- then that memory is free'd.

rust can also share memory by borrowing. borrowing is just a fancy way to describe referencing memory via non-owning pointers.

when memory is borrowed, its ownership temporarily changes, and it becomes immutable to the original owner until it's no longer borrowed. this is how rust's infamous *borrow checker* enforces memory correctness -- by essentially managing read/write/own permissions to heap memory.

mutable borrowing is even more interesting:
```rust
fn main() {
    // v owns this vector
    let mut v: Vec<i32> = vec![1, 2, 3];
    
    // now num becomes the owner and v can't even read anymore
    let num: &mut i32 = &mut v[2];
    
    // you must deference num to get write acess
    *num += 1;
    
    // prints 4
    println!("Third element is {}", *num);
    
    // num is now out of scope 
    // ownership/read/write access to the vec has returned to v
    // prints [1,2,4]
    println!("Vector is now {:?}", v);
}
```

when you do mutable borrowing -- the original owner can't even read the memory it had just owned. i suspect this is going to be tricky to work with for concurrent code.

ok -- but what if you borrow from the borrower? same deal -- ownership changes and the previous borrower loses write access. if the new borrower is also mutable then the previous borrower also loses read access.

it might help to think about this as `[R]ead/[W]rite/[O]wn` permissions:

for immutable borrowing -- we can still read the values from any of our variables at any point in the borrowing chain:
```rust
// immutable borrowing
fn main() {
    // v:R/W/O
    let v: Vec<i32> = vec![1, 2, 3];

    // v:R/-/-
    // num:R/-/O
    let num: i32 = v[2];

    // v:R/-/-
    // num:R/-/-
    // num2:R/-/O
    let num2: &i32 = &num;
    
    // this compiles just fine
    // all references are immutable and retain read access
    println!("v: {:?}, num: {}, num2: {}", v, num, num2);
}
```

vs the same code but as mutable borrowing:
```rust
// immutable borrowing
fn main() {
    // v:R/W/O
    let mut v: Vec<i32> = vec![1, 2, 3];

    // v:-/-/-
    // num:R/W/O
    let num: &mut i32 = &mut v[2];
    
    // won't compile 
    // v lost read access to a mutable borrowing from num
    println!("v: {v:?}");

    // v:-/-/-
    // num:R/-/-
    // num2:R/-/O
    let num2: &i32 = &num;
    
    // this is valid because num2 is a read-only reference to num
    // therefore, num retains read permissions
    println!("num: {num}");
    
    // also works just fine because num2 is a read-only reference to num
    println!("num2: {num2}");
    
    // this works again because num and num2 fell out of scope
    // which results in their loss of ownership/destruction
    // and ownership is returned to v
    println!("v: {v:?}");
}
```

this makes vectors particularly dangerous -- because when you do a mutable borrow, you can end up de-allocating the underlying array if it gets re-sized (so a new array gets allocated and the original de-allocated).

for example:
```rust
fn main() {
    let v1 = vec![1, 2, 3];
    let mut v2 = v1;
    
    // danger! the vector will get re-sized here
    v2.push(4);
    
    // and this won't compile 
    // v1 points to memory on the heap that no longer exists
    println!("{}", v1[0]);    
}
```

however, this fixes our ownership issues:
```rust
fn main() {
// v1 is now mutable
    let mut v1 = vec![1, 2, 3];
    
    // v2 borrows v1 as a mutable ref
    let v2 = &mut v1;
    
    v2.push(4);
    
    // this compiles
    // prints [1,2,3,4]
    println!("{v1:?}");
}
```

## why even own?
if we have read and write perms, then why do we need "ownership" perms too?

well -- we live in a capitalist society -- therefore, the language reflects life[^2].

but actually, it's so that memory cannot be free'd while it's being borrowed.

for example:
```rust
fn main() {
    let s = String::from("Hello world");
    let s_ref = &s;
    
    // we can't deallocate s because s_ref is borrowing it
    // therefore, s_ref currently owns the memory that s points to
    drop(s);
}
```

and that's why there is ownership as a permission in our framework. allocated memory must outlive all its references.

## alright, you can have it back
thinking of ownership as a set of permission checks is an interesting way to frame this. but that mental model really helps make sense of things that I had never considered when working with Go.

at the end of the chapter on ownership was one final example:

```rust
fn first_or<'a, 'b, 'c>(strings: &'a Vec<String>, default: &'b String) -> &'c String {
    if strings.len() > 0 {
        &strings[0]
    } else {
        default
    }
}
```

this function returns a reference of either `strings` or `default`. you'll notice some funky syntax like `<'a, 'b, 'c>` and `&'b`. these are lifetime references[^3]. we're basically stating that the lifetime of the result differs from the inputs.

the reason this won't compile is because the lifetimes of `'a` and `'b` aren't bound to `'c`. but you can bind lifetimes of one reference to another and fix this function by changing `<'a, 'b, 'c>` to `<'a: 'c, 'b: 'c, 'c>`

```rust
fn first_or<'a: 'c, 'b: 'c, 'c>(strings: &'a Vec<String>, default: &'b String) -> &'c String {
    if strings.len() > 0 {
        &strings[0]
    } else {
        default
    }
}
```

now `'a` and `'b` must live as long as `'c`. this might be a bit dangerous -- because if `'c` is long-lived and this function is called a lot then you may end up bloating memory usage.

something like this would also work:
```rust
fn first_or(strings: &Vec<String>, default: &String) -> String {
    if strings.len() > 0 {
        strings[0].clone()
    } else {
        default.clone()
    }
}
```

here we get references -- but we call `clone()` to create new memory with new ownership and a new lifetime. and `strings` and `default` can be de-allocated independently of the result.

[^1]: not actually true. you can still do this by calling `drop()`. and presumably there are many more escape hatches yet to discover.
[^2]: is this timeline even real life? i wish somebody would enforce its correctness. or at least collect the garbage, starting with the white house.
[^3]: i wish i had a reference to a lifetime movie instead.