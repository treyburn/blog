+++
date = '2025-10-11' # date of publication
draft = true # set to false or remove to publish
author = 'Travis Reyburn'
title = 'Go Func Yourself' # official title of the post
displayTitle = 'Go Func Yourself' # display title in content
displayLanguage = 'golang'
subtitle = 'all the rough edges ive gotten splinters from' # subtitle used for display and content
tagline = "no you're the idiosyncrasy" # note on the sidebar
description = '' # seo description? unclear of usecase
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ['go', 'golang', 'idosyncracies', 'footgun'] # seo keywords
+++
## things i hate about go
i've been writing go code professionally since 2019. i was there shaking my fists before generics were added -- and i've used them about a dozen times since.

i actually quite love go. it's got a lot of detractors but `if err != nil` didn't kill my dog so i have managed to find quite a bit of joy in this simple language with its incredible tooling. it hits that 80/20 sweetspot for me. i'm not going to advocate for it for you -- you're a grown up and if you want to use a lesser language (or rust) then be my guest.

no -- instead i want to rant about the pieces of go which actually feel broken to me.

## rage wisdom
there's a saying in the broader go community -- an unofficial proverb -- of `accept interfaces; return concrete structs`. i tried to track down the origin of this. i swear it was rob pike. but i can't actually locate the source. maybe its a covid hallucination. who can say.

anyways -- this particular proverb has quite an issue. go doesn't support type covariance!

what's that mean? it means that go cannot treat `interface Foo` and `struct fooImpl` as the same in certain cases.

here are the biggest issues i've run into with this -- let's say you want to accept a constructor for something which satisfies a particular interface.
```go
package main

type Foo interface {
	Foo()
}

type fooImpl struct{}
func (f *fooImpl) Foo() {}

type BuilderFunc func() Foo

func Operate(f BuilderFunc) {
	foo := f()
	foo.Foo()
}

func NewFooImpl() *fooImpl {
	return &fooImpl{}
}

func main() {
	// this does not compile
	Operate(NewFooImpl)
}
```

[cry it yourself.](https://go.dev/play/p/A6lIp2I8INf)

as it turns out -- you can't! `NewFooImpl` doesn't satisfy `BuilderFunc` because it returns `*fooImpl` -- even tho `fooImpl` satisfies the `Foo` interface. in a language which supports type covarience -- then this would work. but Go is not one of those languages. sometimes you just need to return an interface.

this can be particularly tricky with chainable functions.

a la

```go
foo().add().then().maybe().somethingElse()
```

if you're returning a concrete struct in these chainable methods -- then good luck ever producing an interface for this. i've seen this pattern with frequently and always have to write an ugly adapter for it. if go just supported covariance -- or the community preferred returning interfaces -- then we wouldn't hit the issue so frequently.

another issue is that slices of an interface and slices of a concrete type that implements said interface are not compatible.

```go
package main

type Foo interface {
	Foo()
}

type fooImpl struct{}
func (f *fooImpl) Foo() {}

func Consume(x []Foo) {
	for _, f := range x {
		f.Foo()
    }
}

func main() {
	input := []*fooImpl{
		&fooImpl{},
		&fooImpl{},
		&fooImpl{},
    }
	
	// this does not compile
	Consume(input)
}
```

[cry it yourself.](https://go.dev/play/p/uajUMZXugw6)

you can't even type cast `[]*fooImpl` into `[]Foo` - you'd have to allocate a whole new slice. go func yourself!

## don't panic
go panics give me so much anxiety. did you know that panics in golang are scoped to the goroutine?

i bet you thought you could just do the following:

```go
package main

import (
	"fmt"
	"sync"
)

func handlePanic() {
	err := recover()
	if err != nil {
		fmt.Println("caught a panic!")
    }
}

func panicsOn10(x int) {
	if x == 10 {
		panic("at the disco!")
    }
}

func main() {
	defer handlePanic()
	
	var wg sync.WaitGroup
	for i := range 20 {
		wg.Add(1)
		go func() {
			panicsOn10(i)
			wg.Done()
        }()
    }
	
	wg.Wait()
	
	fmt.Println("all done!")
}
```

[cry it yourself.](https://go.dev/play/p/WueyVZznQGJ)

you think you're safe, right? you've got that top level `defer` in your main -- surely that will catch any panics in your program, right? surely you will get warning when an errant panic happens in prod, right?

we'll that's where you are wrong. `defer recover()` is scoped to the given goroutine. so for every single goroutine that your system produces -- you will need to insert `defer handlePanic()` in there.

what's that -- you're using a 3rd party library which itself spawns many goroutines for its own internal worker pool. better hope that never panics 🤡

while we're on the subject of not panicking -- i bet you thought you could do something slick like this:

```go
package main

import (
	"fmt"
)

func handlePanic() {
	err := recover()
	if err != nil {
		fmt.Println("caught a panic!")
    }
}

func releaseSomething() {
	fmt.Println("we always want to release this")
}

func panicsOn10(x int) {
	if x == 10 {
		panic("at the disco!")
	}
}

func main() {
	defer func() {
		handlePanic()
		releaseSomething()
    }()

	for i := range 20 {
		panicsOn10(i)
    }
	
	fmt.Println("all done!")
}
```

[cry it yourself.](https://go.dev/play/p/1A-3OcJ0dq1)

this defer ensures that we always handle panics AND always release our something, right? yeah i thought that once too. it does not. that `recover()` call is never evaluated and never makes its way into the call stack. so when the panic occurs and the callstack unwinds -- we never get the chance to recover. that `recover()` must be evaluated before the panic occurs -- and by having it called within an anonymous function, it's never evaluated.

yeah ask prod how i learned that one. go func yourself!

## this is not the err you're nil-ing for
yeah yeah yeah. `if err != nil` killed your dog. spare me your drama.

```javascript
// this is so much better! 🤡
try {
    thatBullshit();
} catch(e) {
    theseHands(e);
}
```

errors as values is the future. i don't care about your code coverage or how svelte your code is. i really do not. error handling is every bit as ugly in practice in rust -- so don't even give me that. but we deal with it because we are adults and keeping prod up and running is more important than ugly syntax woes.

no. my issue with `if err != nil` is that it's a fucking lie.

```go
package main

import "fmt"

type MyCustomError struct{
	val string
}
func(e *MyCustomError) Error() string {
	return e.val
}

func DoSomething(x int) error {
	// the default value of all pointers is nil - thus this is nil
	var myError *MyCustomError
	
	if x == 10 {
		myError = &MyCustomError{val: "yep - this is an error"}
		return myError
    }
	
	// still nil here - this is safe
	if myError == nil {
		fmt.Println("look ma - im nil")
    }
	return myError
}

func main() {
	var nilly *MyCustomError
	if nilly != nil {
		fmt.Println("can't reach this - because it's nil by default")
    } else {
		fmt.Println("see! what'd i tell you?")
    }
	
	err := DoSomething(5)
	if err != nil {
		fmt.Println("can't reach this because we passed in 5, not 10. here's the error value even: ", err)
    }
}
```

[cry it for yourself.](https://go.dev/play/p/UDwRLNVXmZ4)

the cake is a lie and so is this god damn error handling. go func yourself!

## the error interface is an err
ok -- this isn't actually something broken in go. i just wish that the `error` interface was more practical.

```go
type error interface {
	Error() string
}
```

seriously -- all we get is a lousy string?!

i understand and appreciate that the go team takes backwards compatability so seriously. i really do. but this is the one area that i wish they would have made a breaking change for.

imagine with me for a moment:

```go
type error interface {
	Error() string
	StackTrace() string
	Wrap(error)
	Unwrap() error
}
```

at some point along the way go added `Unwrap` as an unofficial method to the error interface. there is, however, no `Wrap()` method anywhere. `fmf.Errorf("wrapping here: %w", err)` is the best we get.

`Unwrap()` is what enables `errors.Is()` and `errors.As()` to work. but it's hidden and if you write your own customer error types -- then it's easy to miss and you'll accidentally swallow errors.

speaking of custom error types... i almost always have to bring in [pkg/errors](https://github.com/pkg/errors) because i want to know the stacktrace when an error occurred in production. it feels insane to me that this isn't available by default. i understand there's a perf cost associated with a stacktrace. my suggestion to those that are writing perf critical code in a garbage collected language where they can't handle their error types including a stack trace is to ... write their own custom error type! 🤡

instead, the rest of us are forced to do insane things like write our own linters to identify error paths that might not have a stack trace and enforce our custom error type usage in production codebases.

go func yourself!