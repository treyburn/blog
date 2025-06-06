+++
date = "2025-05-04"
draft = true
author = "travis reyburn"
title = "hola mundo"
subtitle = "the journey of creating my blog"
tagline = "trials and tribulations of getting this thing up and runnin'"
description = ""
summary = ""
aliases = []
tags = ["blogging", "ai", "podman", "just", "hugo", "cloudflare", "porkbun"]
+++
## why?

building my own blog is a can i've been kicking down the road for years. 

when the idea first took root, i think it was for misaligned reasons. at the core -- i wasn't interested in blogging, but in building a static site rendering engine. i wasn't as fully engaged at work. my left and right brains were screaming in agony from building overly complex, buggy crud applications.

i just wanted to carve dovetails by hand, *not build yet another shed*.

thankfully now, i have managed to dumb-luck myself into a job where i find work -- dare i say -- satisfying? 

and that satisfaction has let my yearning turn more practical. maybe one day i'll build that *blazingly fast*, *memory-safe* static site rendering engine with *fearless concurrency*; but for now, i just want to *yeet* my thoughts into the void. 


## ok but you're still building a site from relative scratch?

look. 

i never said i wouldn't do *some* building. you can have your motorcycle maintenance; this is my zen.

i've been thinking a lot about the old internet. the old internet was ugly. it was a mess. it was **rad**.

how did we end up in a world where there are really only a handful of sites that get much traffic? where did that old diy/punk ethos go?[^1]

i blame the zuck. tom let you make your space a mess, and we were all the better for it. a sterile environment kills the creative spirit. it lets the money flow that the grunge once kept dammed away. it was garlic to these vampires.

-- rant over --

i want to build my own blog, relatively from scratch, because i don't *like* the modern blogging platforms. they're bloated, monetized, and don't respect their readers. i don't want a paywall. i don't want analytics. i don't crave engagement. i just want my site to live in your neighborhoods CDN. this is my funny sticker on a light-pole.

thus i arrived at my requirements:
- the site must be static
- absolutely no javascript
- the content must be written in markdown
- sufficiently flexible for my styling requirements
- the tooling i choose must be a relative joy to use


## tooling chosen
[hugo](https://github.com/gohugoio/hugo) was the obvious choice for me. it's battle tested, highly flexible, written in my preferred language[^2], and open source.

but before we could get to work -- i had some [yaks to shave](https://www.youtube.com/watch?v=v3mNf1v3rqc).

### os
my personal computer is windows. it's tragic. but it is what it is when my computer was built for gaming.

i've used wsl in the past. don't listen to the windows zealots on hn -- it's ok at best. when it works. but in my experience its buggy, unstable, and has bitten me repeatedly. frankly, i find the idea to be kafkaesque.

it was time to break free from my shackles; it was time to install linux.

#### pop!_os
i opted to use [pop!_os](https://system76.com/pop/) as my distro. i like the focus on devex, out-of-the-box support for nvidia gpus, taking the best parts of ubuntu with a better core component update schedule, the [snazzy tiling engine](https://system76.com/pop/workflow/), and i wanted to support the [brave new world](https://system76.com/cosmic/).

pop!_os feels like the closest a desktop linux distro has gotten to the *it-just-works* experience of macOS.

but first i needed to order a new nvme drive and a usb 4.0 thumb drive.[^3]

...

[installation was a breeze](https://support.system76.com/articles/install-pop/), and we were up and running!

but.

there was something bugging me. the bootloader. it pained me to have to hold f2 every time i wanted to boot into my secondary os.[^4]

#### bootloader customization
i needed a bootloader. i had used [grub](https://www.gnu.org/software/grub/) in the past. but man. it's just so ugly. pop!_os also uses systemd. and i wanted something with a pretty ui.[^5]

so i found [refind](https://www.rodsbooks.com/refind/) and a [relatively minimal theme](https://github.com/2KAbhishek/refind2k) for it. but it was not drama free. boots were **painfully** *sloooow*. so i hacked at the config for an afternoon before finally giving up.

the next day, i booted in, and it was lightning fast to load.[^6] I guess the issue was weirdness with the umpteen-million reboots? idk. whatever. at some point i need to set these configs properly because honestly its *jank*. but it works. maybe i should consider a better [theme](https://github.com/martinmilani/rEFInd-theme-collection) -- surely that will fix the problem.[^7]

### containers
ok - so we've installed a new nvme drive, installed pop!_os, and dealt with our bootloader compulsions. we're ready to blog!

*not so fast.*

we're not just going to `apt install hugo` like a heathen. no, no, no. we're going to containerize hugo -- and we must use [alpine linux](https://www.alpinelinux.org/) so that our container is light, snappy, and starts up ever so slightly faster.[^8]

also -- we're going to try out [podman desktop](https://podman-desktop.io/) since its linux support seems so good.[^9]

ah but there is a catch -- as it turns out, hugo has a cgo dependency.[^10]

so i did what every "sane" software engineer does when met with a challenge they don't really want to do. i vibe coded it. 😎

as it turns out -- the new [jetbrains coding agent](https://www.jetbrains.com/junie/) is actually pretty incredible! i've tried out [cursor](https://www.cursor.com/en) in the past, but i found that the model flailed a lot and just produced *too much* code for me to keep up with. also, i just generally prefer jetbrains ide's to vscode -- and i like the jetbrains ethos.

unlike cursor, the jetbrains agent is slower, produces much smaller changesets, and prompts me for further instructions when things are unclear. still not worried it's going to take my job, but it's done surprisingly well!

anyways, after some back-and-forth junie vibe coded this for me:
```dockerfile
FROM docker.io/golang:1.24.2-alpine

ENV HUGO_VERSION=0.147.1

# Prerequirements
RUN apk add --update --no-cache gcc musl-dev build-base git

# Compile from source
RUN CGO_ENABLED=1 go install -tags extended,withdeploy \
    github.com/gohugoio/hugo@v${HUGO_VERSION}

WORKDIR /src

ENTRYPOINT ["hugo"]
```

it doesn't look like much. and it's not. but junie actually simplified the file quite a bit after i made it overly complex while chasing down some issues with css compilers.[^11]

an ai that will remove code passes my personal turing test. way to go junie.

### command runner
ok! we've got linux installed, podman installed, and hugo is containerized!

now we're ready to blog, right? hahaha -- no.

i'm not just going to `podman run -ti -v .:/src --entrypoint /bin/sh hugo:latest` and run commands directly. oh no -- i need to make sure my commands are easy to remember as i am sharing them with many people.[^12]

in the past, i'd use `make` for such a thing. lately, i've been using `docker compose` as a container task runner. this time, however, i think i'm gonna test out a shiny new toy.

[just](https://github.com/casey/just) looks to fit the bill for my personal next-generation task runner of choice -- and it's written in rust![^13]

as it turns out, its documentation and usage across the internet is sufficiently widespread -- so junie had no issue vibe coding a bunch of common commands for me.

off to the races!

### hugo and friends
as i mentioned previously, i selected hugo as my static site gen tool. it hits all the requirements pretty well and there's zero javascript involved.

well -- that's not entirely true. i actually wasted a few hours because i thought it was true. but themes can and sometimes do pull in javascript. particularly around css compilers. i had a nice theme picked, but ended up wasting the better part of an afternoon battling node and css and alpine linux and hugo dependency resolution in my container.

it was an utter waste of time and further cemented my long smoldering annoyances with the javascript and web ecosystem as a whole.

to be fair -- i did this to myself.

but in the end, i settled on a new theme -- [risotto](https://github.com/joeroe/risotto).[^14] i've since modified it a fair bit to meet my needs and am quite happy thus far. it also served as a pretty excellent example of how to work with hugo to create a simple site. kudos for that.

thus, we have arrived at the current station. i won't bore with details on how to use the go templating syntax + html that hugo provides. but i will say that i'm glad i had plenty of previous experience with this from writing plenty of codegen tooling in Go at work. this might have been a bit more of a wild ride otherwise. it's still not totally clear what variables are available and when -- but we'll get there through practice.

### deployment
i've decided that i'm going to use [cloudflare pages](https://pages.cloudflare.com/).

i am a little bit suspicious that this will end up being a regrettable choice.

**pros:**
- their [hugo integration](https://developers.cloudflare.com/pages/framework-guides/deploy-a-hugo-site/) looks about as easy as it can get for me.
- cloudflare does some seriously cool, cutting-edge work. maybe i could shoehorn in usage of [cloudflare workers](https://workers.cloudflare.com/) one day for interactive elements like comments?
- [1.1.1.1](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) is the kind of critical infrastructure that should not be controlled by ad-fueled conglomerates.

**cons:**
- man, they hired freaking [mark anderson](https://www.cloudflare.com/press-releases/2024/cloudflare-appoints-mark-anderson-as-president-of-revenue/).[^15] this is an incredibly sus choice and is the primary reason that i think i will one day come to regret selecting cloudflare as my host+cdn.

anyways, setting up the cloudflare process was a breeze. you just create an account, make your repo public, then create a new page pointed at your repo and target branch.

the key bit to remember was to set the following so that urls work correctly:
```shell
hugo -b $CF_PAGES_URL
```

And we're off the races!

... almost. it turns out that there are some kinks to work out with regarding our usage of a git submodule for the risotto theme.[^16]

first, it seems that cloudlfare needs to use ssh instead of https. makes sense; me too.

```text
[submodule "/src/blog/themes/risotto"]
	path = /src/blog/themes/risotto
	url = git@github.com/joeroe/risotto.git
```

voilà! ... nope. still not building.

after more digging, it turned out that this was not the case. in fact, this was straight up wrong. **shakes fist** @ [stackoverflow](https://stackoverflow.com/a/78291745).

in the end, it was my desire to containerize and script with just which bit me. i did this to myself. 

the git submodule handling was incorrect - so a quick `git rm` and a cleanup of `.git/modules` and then re-creation of the submodule with `git submodule add https://github.com/joeroe/risotto blog/themes/risotto` and we are [deploying](https://github.com/treyburn/blog/pull/10)! 🚨

it's still under a garbage random `https://8b695abe.blog-9zz.pages.dev/` domain. but we are one step closer!

### dns

> It's not DNS
> There's no way it's DNS
> It was DNS


i bought this domain in one of my *this-is-a-great-idea-i-should-buy-the-domain* binges[^17] back when google domains [was still a thing](https://killedbygoogle.com/). now it's managed by squarespace. i guess they're probably fine? idk, they seem kinda sus and [porkbun](https://porkbun.com/) has branding that just vibes with me too much. the pig **gets** me. 

so, i'm going to transfer domain ownership for this blog. wish me luck.

...

-- TODO: write up switching cloudflare over to my custom domain via porkbun

## that's a wrap
so we have it. the journey is complete. 😤

now i've just got a few items on my todo:
- ~fix my janking css styling on mobile~
- ~figure out how to make my footnote refs small so i dont have to pollute my markdown with `<small><small>[^n]</small></small>`~
- improve my styling around multi-line quotes
- css animations?! welcome to my nightmare.
- figure out what the heck i'm gonna write about next

[^1]: it's still here; you just need to [look for it](https://blog.kagi.com/small-web) -- these not the sites the ~~jedi~~ google would show you.
[^2]: for inevitable debugging.
[^3]: this was totally unnecessary and absolute overkill -- but hey my mobo supports it.
[^4]: sorry pop -- this is you.
[^5]: it's not vanity; it's *aesthetic*.
[^6]: <img alt=":cowboy-cry:" src="/images/cowboy-crying.png" width="45"/>
[^7]: <img alt=":clown-makeup:" src="/images/clown-makeup.png" width="45"/>
[^8]: <img alt=":clown-bread:" src="/images/clown-bread.png" width="45"/>
[^9]: podman desktop, as it turns out, is the bees knees! i can't believe i've been using docker desktop over podman for so long. i'll have to write a blog post just about this at some point, but so far i'm super impressed. containers are rootless by default! gone are the file perm issues associated with creating files from inside a container mounted to your local dir!
[^10]: CGo is not Go. Nor is it a [pipe](https://en.wikipedia.org/wiki/The_Treachery_of_Images).
[^11]: just say 'no' to [sass](https://sass-lang.com/)
[^12]: yes i am those people and man does future me need a lot of hand-holding on how to use tooling.
[^13]: that's how you know it's a serious project and won't just be abandonware in a few years. 🙈
[^14]: yes i picked it because i love italian food, but i stayed for the terminal vibes.
[^15]: mark anderson was the buffoon that took over as the ceo of alteryx when its founder, dean stoecker, stepped down. dean was kind of a mess, but at least he understood why people loved designer. mark anderson, and the sycophants he hired, were clueless trend chasers. he fundamentally did not understand alteryx's value prop. and because of that, he directly harmed my friends, colleagues, and literal family via wave after wave of needless layoffs due to his ineptitude. he destroyed that company, and he personally cost me a good chunk of my life's savings by wrecking alteryx stock. seriously, fuck that guy. it's so disheartening to see a buffoon like that fail upwards just because he's giga-wealthy. eat the rich.
[^16]: git submodules; not even once. just say no, kids.
[^17]: am i really the only one spending hundreds a year on unused domains from half-baked ideas? don't judge me.