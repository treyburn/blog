+++
date = '2026-04-10' # date of publication
author = 'Travis Reyburn'
title = '6 Months of Linux Gaming' # official title of the post
displayTitle = '6 Months of Linux Gaming' # display title in content
shortName = 'gaming' # short name for nav dropdown
displayLanguage = '1337speak'
subtitle = 'it is so over for microslop' # subtitle used for display and content
tagline = 'surely 2027 will be the year of the linux desktop' # note on the sidebar
description = 'My 6 month review of linux gaming. Honestly? It just works. It is SO over for windows.' # RSS feed description - keep brief
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ["linux", "gaming", "windows"] # seo keywords
+++

## 3 score...
i've been a pc gamer since i was knee-high to a grasshopper. my dad was an OG dork; one of the first remote tech workers - from 1993 on - out in the boonies of cornlandia. ran his own little 2 man startup for a bit. in retrospect - mad respect.

because of that semi-privileged upbringing, we always had a computer and an internet connection. and i've realized as an adult - that we got this way earlier than most kids. especially the other kids in cornlandia. it's probably why im a software dev today.

anyways - i remember my first game. my dad and i were getting ... whatever it is you used to have to get from staples in the 90s - and i saw it. [mech warrior 2](https://en.wikipedia.org/wiki/MechWarrior_2:_31st_Century_Combat). i had to have it. my dad had to have it. we got it and bailed on whatever it was we were supposed to be buying and went straight home.

we threw it on my dads ms-dos machine and away we went. 3d graphics! just roaming around this .... most empty sand world shooting tiny specs of mech we could barely see. and it was glorious. i was hooked.

a few months later - i entered kindergarten and met my fellow nerds. one of them had a dad that worked as a sysadmin - so they had a 3 family computers, a lan network, and warcraft 2. holy moly - that was it. i was a true pc gamer from then on.

## ...and 6 months ago
like all pc gamers - i've been gaming on windows my whole life. from ms-dos to windows 11. it was old reliable - until it wasn't.

i'm not gonna dive to deep into my gripes with windows - so ill just leave it as:

> what the actual fuck have you done, satya? how have y'all enshitified a freaking operating system this hard this fast. just what the greedy fuck!
{.styled-quote}

btw - if you're still suck on windows then [take this debloat script and breath easier](https://github.com/raphire/win11debloat).

i used that debloat script personally for ages. i still use it on my wife's machine. it's safe, it works, and i vouch for it. you'll need to run it after every update - but just consider that the microslop tax.

anyways - 6 months ago i decided that enough was enough. i dont even know what the straw that broke the camel’s back was. all i know is i was *so over it*.

i decided it was time to give linux gaming a fair chance. i had [moved my personal dev env](https://treyburn.dev/posts/2025_05_04_my_first_post/) over to pop!_os about a year ago and was [mostly loving it](https://treyburn.dev/posts/2025_05_31_adventures_in_linux/). so i figured i might as well do the same for gaming. at least give it a shot.

## yak shaving
i could have taken the easy way and just installed steam on pop!_os. it totally would have worked. but i'm not one to avoid a nice bike shed - so i decided to try a new flavor of linux.

i narrowed it down to the two hyped gaming distros:

* [cachy-os](https://cachyos.org/) - a performance-first distro built on arch. basically cachy recompiles everything with all the highest level `-o` flags it can get away with, narrows the target hardware to modern equipment to get even more efficiency out of the compiler, and ships some custom kernel patches and a latency-minimizing scheduler.
* [bazzite](https://bazzite.gg/) - a gaming focused distro built on an immutable fedora distro and cloud native tooling (containers + [bootc](https://github.com/bootc-dev/bootc)). the biggest selling point of bazzite is the ease of upgrades and rollbacks.

as much as i was extremely interested in the perf improvements of cachy - i couldn't help but be nerd-sniped by bootc[^1] and the immutable aspect. i didn't really understand how a distro could be immutable[^2] - but it sounded really cool. and cloud native? well thats what i do for work - so surely this os would just click for me.

and honestly - it does! it has been an absolute joy to use. every once in a while i boot in and update via `ujust update` in my terminal (pretty sure you can do it in the ui too, but i don't know how) and that's it. no drama. the one time i had an issue and wanted to rollback? literally just `brh rollback`. that was it. i couldn't believe it!

## games i've played
so you're probably wondering what i've actually played. surely i've cherry-picked games to make linux look good, right? nope.

i used to check [protondb](https://www.protondb.com/) before installing any games to be sure they would work. i've stopped doing that and just go straight to installing. it all just works.

all the games have been from my steam library - or my epic games library via the [heroic games launcher](https://heroicgameslauncher.com/). if you use other platforms - your mileage may vary. i would expect the microslop gamepass stuff to be extremely hard to configure properly. but i might be wrong!

anyways - this is the full list - judge away!
* [arc raiders](https://store.steampowered.com/app/1808500/ARC_Raiders/)
* [stalker 2](https://store.steampowered.com/app/1643320/STALKER_2_Heart_of_Chornobyl/)
* [kingdom come deliverance 2](https://store.steampowered.com/app/1771300/Kingdom_Come_Deliverance_II/)
* [doom the dark ages](https://store.steampowered.com/app/3017860/DOOM_The_Dark_Ages/)
* [timberborn](https://store.steampowered.com/app/1062090/Timberborn/)
* [pacific drive](https://store.steampowered.com/app/1458140/Pacific_Drive/)
* [baldur's gate 3](https://store.steampowered.com/app/1086940/Baldurs_Gate_3/)
* [disco elysium](https://store.steampowered.com/app/632470/Disco_Elysium__The_Final_Cut/)
* [peak](https://store.steampowered.com/app/3527290/PEAK/)
* [alan wake 2](https://store.epicgames.com/en-US/p/alan-wake-2)
* [rv there yet](https://store.steampowered.com/app/3949040/RV_There_Yet/)
* [pentiment](https://store.steampowered.com/app/1205520/Pentiment/)
* [yapyap](https://store.steampowered.com/app/3834090/YAPYAP/)
* [case of the golden idol](https://store.steampowered.com/app/1677770/The_Case_of_the_Golden_Idol/)

## the good, the bad, the ugly
that's a lot of games - surely must have been a lot of effort tweaking configs to get them to run, right? nope. literally no effort beyond clicking install and running.

i've had exactly 1 issue and 1 gripe during my six months and many games.
1. gripe: it was annoying to get 1password installed. they didn't have it on flathub at the time - [but it's there now](https://flathub.org/en/apps/com.onepassword.OnePassword). so this was more of a minor annoyance with how to install software outside the blessed path. but even then - it just involved a simple cli command. that might be a barrier for some - but i literally only to install this program like that. everything has had flathub support for casual/gaming oriented software. stuff like slack, discord, spotify, brave browser, steam, heroic, etc - all that is in flathub.
2. issue: one of the nvidia driver updates that came with a bazzite system update made stalker 2 unstable. this was annoying to track down but once i figured out why my game was randomly crashing - it was as simple as figuring out which version last worked, then running `brh list` to get the target value and `brh rollback <target>`. that was it! back to working. every so ofter i'd try to update, see it was still broken, and rollback again. eventually a new driver shipped that fixed it and that was it.

point number 2 i listed as an issue. and it was. but it's also kind of a huge selling point of bazzite. what if my game was broken on windows like that? have you ever tried to rollback windows or an nvidia driver on windows? it's fucking miserable. i am totally sold on the immutable, container-based os approach with bazzite/bootc/fedora-atomic. for an "appliance" os (which i consider gaming to be a form of) - i cannot possibly imagine a better setup[^3].

you're probably wondering if i've had any issues with the desktop ux? nope. kde plasma is actually pretty slick. the window tiling could maybe be a bit more intuitive - but otherwise it feels like a better windows desktop environment. seriously. the start menu in particular is so good. i wouldn't recommend something like cosmic desktop to casual users - theres still lots of rough edges here. but kde plasma is great - a real no-brainer to use and will just feel familiar to the less tech-savvy.

ok but what about peripherals? we've all heard linux is terrible with peripherals. and maybe it was once - but this truly hasn't been my experience. i've got the following:
* bog standard mouse and keyboard: no issues. 
* 2 monitors (an ultrawide 1440p 240hz monitor and a vertically oriented 1080p 144hz monitor): no issues. 
* an xbox gamepad with its proprietary dongle: no issue.
* long range bluetooth antenna to talk to some random devices: no issues.
* wifi7 antenna: no issues.
* fancy corsair headset with a proprietary dongle: no issues.
* logitech high-res webcam over usb-c: no issues.
* wired desktop speakers: no issues.

i want to really drive this point home - every device i've connected has just worked out-of-the-box. on bazzite and pop!_os alike. that literally hasn't been the case on windows. my wifi7 antenna didn't work on windows. i had to use another computer to download a driver and throw it on a flash drive for windows because it wouldn't work. what if i didn't have another machine to do this with? ugh windows wtf.

literally less stuff works out-of-the-box on windows than linux has been my lived experience over the past year. we've been lied to!

## over and out
so what's next?

i literally haven't booted windows once since installing bazzite. 

my plan is this: if i make it the remainder of the calendar year without needing to boot windows, then we are wiping that drive and ridding our system of microslop.

after that? i think i wanna test out [bluefin](https://projectbluefin.io/). an immutable dev env with bootc? if it works then holy moly. not to mention the dinosaur theme. my god, the dinosaur theme! it feels like this is meant to be. don't let me down bazzite!

oh and gaming wise? well once i finally finish kingdom come[^4] then it's off to get weird in [death stranding 2](https://store.steampowered.com/app/3280350/DEATH_STRANDING_2_ON_THE_BEACH/).

[^1]: written in rust, btw
[^2]: turns out - this just means that userspace is semi locked down. your programs and their deps aren't allowed to mess with the system. that's basically it. think of it like the underlying system is a git submodule that you're based on. you can't modify it - but you can control the version of it.
[^3]: in the future i am curious to check out [bluefin](https://projectbluefin.io/) - also from the ublue org that makes bazzite. im not sure if an immutable distro will work for my dev env. but it might! and it'd be pretty amazing if it does. so we shall see. also extremely interested in [ucore](https://github.com/ublue-os/ucore) as my future nas/homelab os. fedora core-os+bootc based, ships with zfs by default, and can upgrade/rollback in place? holy moly this feels like the future of home servers.
[^4]: im so close - only like another 100 hours left! lol