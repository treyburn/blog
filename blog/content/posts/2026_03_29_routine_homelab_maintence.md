+++
date = '2026-03-23' # date of publication
author = 'Travis Reyburn'
title = 'Routine Homelab Maintence' # official title of the post
displayTitle = 'Routine Homelab Maintence' # display title in content
displayLanguage = 'dorklang'
subtitle = 'theres no place like 192.168.50.255' # subtitle used for display and content
tagline = 'less a homelab and more a homechihuahua' # note on the sidebar
description = 'Getting my pihole back online' # seo description? unclear of usecase
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ['homelab', 'pi', 'pihole', 'pi-hole', 'raspberrypi'] # seo keywords
+++
## chaos reigns within
it's been a minute since my last post -- so i figured i'd give an update on the most exciting thing to happen[^1] since: my pihole[^2] stopped working.

i know -- super cereal -- but i've been running this thing on my **super overkill** RaspberryPi5 for about a year now without incident. it's been a set-it-and-forget-it ad killing machine[^3] for my entire home network, and you should get one too.

anyways -- this thing totally stopped working out of the blue a couple of weeks ago. i tried kicking it a few times -- and it'd work for a few minutes -- then fall over again. over and over and over.

## repent, reflect, restart

i figured something may have gone wrong with the storage? i checked if i had accidentally left the sd-card in (i didn't) as i had installed an nvme drive hat[^4] which should have been used as the only disk storage (it was).

next, i reconfigured my entire desk setup[^5] so that i could plug the rpi5 straight into my monitor + keyboard + mouse instead of mucking around with ssh connections that would mysteriously die after a few minutes. surprisingly - everything seemed ok? the rpi was totally stable -- except the internet would stop working on the rpi5 after a few minutes. sus.

## trying to find the guy who did this

ok so i turned off pihole via `docker compose down` and had already stopped serving dns traffic to the rpi via my router. yet the internet connection kept dying. maybe my cables were going bad?

so then i spent the better part of an hour trying different cables and ports on my router. eventually i was convinced it was my router going bad -- but after a whole hell of a lot of cable unplugging/re-plugging over and over and testing against my tower -- i came back to the conclusion that it was something going on with the rpi5.

so then i hooked it up to wifi via a usb dongle -- as maybe the issue was the physical ethernet port (i had had an ethernet port go bad on my towers mobo[^6]). thankfully -- the internet connection died just as fast on the wifi dongle. woo!

so what was it? i was pretty stumped -- so i asked my buddy claude for an assist.

> hey claude - how can i see which processes have the most network connections?
{.styled-quote}

> you need to run the following:
> 
> `ss -tunap | awk -F'"' '/users:/{print $2}' | sort | uniq -c | sort -rn | head`
{.styled-quote-2}

and sure enough...

```shell
$> ss -tunap | awk ...
      24938 rz-agent
      ...
```

i forgot that i had [runzero](https://www.runzero.com/) performing regular scans on my network because i had a jank router setup that kept giving out different IP addresses to our home devices which was mucking with blocklist groups i had configured...

extremely funny that the company that burned me out so hard from the endless prod fire drills and customer support bug triaging came back to haunt me with 1 final bug.

whatever. yeeted that shit off my machine, and we now were back in business.

## order shall return

while i was in here - i decided it was high time to properly un-fuck my setup that i vibe coded back before the agents were any good.

so here we go!

new docker compose setup - somehow drastically simplified and little features like being able to resolve `pi.hole` on my home network finally worked.
```yaml
# docker-compose.yml

services:
    pihole:
        container_name: pihole
        image: pihole/pihole:latest
        network_mode: host
        environment:
            TZ: "America/Denver"
            FTLCONF_webserver_api_password: ${PH_PASS}
            FTLCONF_dns_listeningMode: all
            FTLCONF_dns_hosts: |
                192.168.50.255 pi.hole
                192.168.50.1 my.router.com
        volumes:
            - "./etc-pihole:/etc/pihole"
        cap_add:
            - NET_ADMIN
        restart: unless-stopped
```

Then I fixed some of the earlier jank in my systemd pihole.service.
```ini
# /etc/systemd/system/pihole.service

[Unit]
Description=Pi-hole Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=~/pihole
ExecStart=docker compose up -d
ExecStop=docker compose down
TimeoutStartSec=15

[Install]
WantedBy=multi-user.target
```

Then I decided I wanted to fix my cron job for pulling the latest pihole docker image/rebooting on a monthly cadence so that it'd actually work.
```shell
# crontab

0 4 1 * * cd ~/pihole &&
    docker compose pull &&
    docker compose up -d --remove-orphans
```

and that's it folks! things have been rock solid since. next step is to get https enabled, stand up traefik as a reverse proxy in front of the pihole - then start adding other docker compose services like [forgejo](https://codeberg.org/forgejo/forgejo) so that we can yeet more microslop outta our lives.

[^1]: ok but for real -- the most exciting this is that i am back to hiking! 
[^2]: sorry folks -- not my pie-hole -- [this dorky thing](https://pi-hole.net/). 
[^3]: [this machine kills fascists too](https://github.com/antifa-n/pihole).
[^4]: not to be confused with the [brotherhood of funny hats](https://tvtropes.org/pmwiki/pmwiki.php/Main/BrotherhoodOfFunnyHats).
[^5]: cries in poor cable management.
[^6]: [mfw](https://www.youtube.com/watch?v=QACY04l5OHo).
