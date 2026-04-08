+++
date = '2026-04-08' # date of publication
author = 'Travis Reyburn'
title = 'Mirror Mirror in the Cloud' # official title of the post
displayTitle = 'Mirror Mirror in the Cloud' # display title in content
displayLanguage = 'golang'
subtitle = 'taking ownership of my Go modules' # subtitle used for display and content
tagline = 'stop trying to make sovereign happen' # note on the sidebar
description = 'Building a static site generator for vanity Go module domain redirects. Kick GitHub to the curband take ownership of your Go module namespace!' # RSS feed description - keep brief
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ["golang", "self-host", "modules", "sovereign", "vanity domain", "go module"] # seo keywords
+++
## who is the most sovereign of them all?

last week i was headed home from a work trip in bozymandias[^1] and i saw an advert for some bougie hunting clothing/lifestyle brand that just said `you are sovereign` beneath some hunter on a ridge line. besides making me chuckle that owning some 500$ camo jacket is apparently somebody's ideal of "sovereign", it got me thinking about my ideals and how sovereignty fits pretty neatly into them. 

part of why i have started earnestly looking into self-hosting and running my own [homelab](https://treyburn.dev/posts/2026_03_29_routine_homelab_maintence/) is that i am tired of depending on these vampire owned saas companies constantly degrading my experience as a user. enough with the enshitification!

at least with open source i can fix things, tweak things, migrate, or fork and write my own. thats the ideal anyways - and that feels like true sovereignty to me.

## on the microslop conundrum
enter github. github used to be great - and in a sense it still has its old charms thats kept us there. but its increasingly buggy, unstable, and filled with half-baked ai features[^2].

i'd like to move off it at some point. [codeberg](https://codeberg.org/) and [tangled](https://tangled.org/) both appeal to me. i love the e[thos of codeberg](https://docs.codeberg.org/getting-started/what-is-codeberg/#our-mission) and i am especially interested in [tangled's nix-based ci system](https://blog.tangled.org/ci/). but they both have a pretty major downside to me - neither supports private repos. so what am i to do?

i think my ideal is to self-host my own [forgejo instance](https://codeberg.org/forgejo/forgejo). although i must say that i don't love that they copied github actions as their default ci. i understand why they did it; its a system everybody knows and this makes forgejo a near drop-in replacement for people wanting to migrate off github. but i still think that github actions have gone stale as an idea and gitlabs pipelines were a better system. im hopeful that tangled's spindle may pave the way for lighter, faster, more cache-friendly, deterministic ci. it feels like nix/nixOS has such a compelling use-case here. we shall see!

so for the time being - i am stuck on github. but what of my code? i am working on a piece of software i plan to open source "soon" which i feel will have some real traction. what happens to my future users if i want to ditch microslop and move to greener pastures?

## dude where's my code?

for a language with centralized package repository - like rust with cargo, or python with pypi - it's not actually that big a deal to move your codes origin. but in a twist of irony, the decentralized system of go's modules makes this much harder.

go forces you provide your own namespace when you create modules and packages and tools to share. that's pretty neat! you can even host your own proxy and be completely self-reliant with nothing keeping you on google's infra.

the convention when making a go module is to provide the git repo where your code lives. for most of us thats github and our users run `go get github.com/treybrun/my-sweet-code` to share the code we've given to the community. go uses git behind the scenes - so this was the path of least resistance. see the issue?

well - what if i want to move off github? what happens? unfortunately - there's not much you can do if your namespace is your origin. you're more or less forced to [deprecate your code](https://go.dev/ref/mod#go-mod-file-module-deprecation) and provide a new alternative and hope your users follow. breaking dependencies is harmful to users - and i'd like to avoid that.

so what can be done? well - as it turns out - go lets you provide redirects. the first time I encountered this was when I used `zap` - a structured logger by uber. you retrieve their code by running `go get go.uber.org/zap` - yet if you visit [go.uber.org/zap](https://go.uber.org/zap) it redirects you to their [pkg.go.dev](https://pkg.go.dev/go.uber.org/zap) docs page. and in their docs page you can discover that their code actually lives in ... [github](https://github.com/uber-go/zap!

yet if you run `go get` directly against their github - you get the following error:
```shell
> go get github.com/uber-go/zap

go: downloading github.com/uber-go/zap v1.27.1
go: github.com/uber-go/zap@upgrade (v1.27.1) requires github.com/uber-go/zap@v1.27.1: parsing go.mod:
        module declares its path as: go.uber.org/zap
                but was required as: github.com/uber-go/zap
```

## these are not the codes you are looking for
not the most useful error message - but it basically says:

> the code lives here - but you need to get it from elsewhere.
{.styled-quote-2}

well that's kinda neat. how does this work? earlier i said that go uses git behind the scenes to retrieve the code. that's partially true - but not the whole story. turns out Go actually supports a bunch of difference vcs types including git, mercurial, svn, fossil, and bazaar. 

turns out you can declare your module like this `github.com/some-repo/some-pkg.git` then go will immediately use git to resolve your dep. similarly `gitlab.com/repo/some-pkg.svn` will use `svn` to resolve your dep. and so on and so forth.

so then how does `github.com/some-repo/some-pkg` work? or `go.uber.org/zap` for that matter? in neither case was it declare that the code is served via git.

as it turns out - in those cases the go toolchain makes a simple http request to the url with a `?go-get=1` query param added and it expects an html response with some specific `<meta>` tags that direct the go toolchain on where and how to resolve the code.

in fact - this is the entirety of what you need serve for a basic go module redirect including automatic redirection to your `:
```html
<!DOCTYPE html>
<html>
    <head>
      <meta charset="utf-8">
      <meta name="go-import" content="your.domain.com/your-package git https://github.com/repo/your-package">
      <meta name="go-source" content="your.domain.com/your-package https://github.com/repo/your-package https://github.com/repo/your-package/tree/main{/dir} https://github.com/repo/your-package/blob/main{/dir}/{file}#L{line}">
      <meta http-equiv="refresh" content="0; url=https://pkg.go.dev/your.domain.com/your-package">
    </head>
</html>
```

if you serve this `index.html` at the domain/path your go module declares - then you're set!

check out the [official docs on this here](https://go.dev/ref/mod#vcs-find) if you want the know a bit more of the nitty gritty.

## lord of my domain
static site pages on a custom domain is all that's actually required - [ive done this before](https://treyburn.dev/)!

i decided to see what others have done. there's a bunch of server-based solutions from google, caddy, and others. i nixed those because i don't want to run any code - just serve static pages from some host for free. im already doing this with cloudflare pages - so i decided to just stick with that.

so i looked for some static site generators for this - there's actually a bunch of them! including some plugins for [hugo](https://gohugo.io/). most are pretty minimalist and probably would have worked fine.

to be honest, i was kinda just itching to work on a project - and i already punted on [writing my own static site generator](https://treyburn.dev/posts/2025_05_04_my_first_post/) to get this site off the ground. so i figured i finally had a reasonably small project to let me write my own static site generator.

and with that [vanity](https://github.com/treyburn/vanity) was born. as you can imagine - vanity uses vanity to serve itself. and you can see how i actually deploy this in my [pkgs repo](https://github.com/treyburn/pkgs).

try it out!

```shell
go install go.treyburn.dev/vanity@latest
```

now you can view all my published Go modules here: [go.treyburn.dev](https://go.treyburn.dev/)

spoiler alert: it's just `vanity` for the moment. but i promise im working on more!

at the moment - it's just plain-jane static html with zero styling. eventually i'll get around to extending `vanity` so that i can include my own customization and styling and make it look as snazzy as my blog does.

i think that's all for now. if i've got the energy later then ill do a follow up post on how i actually built this thing.

[^1]: bozeman is an interesting place. it's like an alter ego of fort collins - focused on hunting instead of biking. i kinda love the vibe of the town - don't like the like sprawl or the weird new money vibe that the yellowstone larpers brought from texas.
[^2]: this isn't even a new phenomenon. i understand that github is seeing a phenomenal increase in traffic with ai tooling. i understand they also started a fraught move off their own infra to azure. but this instability goes back to 2022. idk what happened then - maybe they started moving core systems out of their ruby monolith? but either way - that was the beginning of the decline that we are so used to hitting today. maybe a decentralized system like git was never intended to be so centralized on a platform like github. call me a radical.