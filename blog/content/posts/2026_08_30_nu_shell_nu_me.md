+++
date = '2026-08-30' # date of publication
author = 'Travis Reyburn'
title = 'Nu Shell Nu Me' # official title of the post
displayTitle = 'Nu Shell Nu Me' # display title in content
shortName = 'nushell' # short name for nav dropdown
displayLanguage = 'nushell'
subtitle = 'nu shell, who dis?' # subtitle used for display and content
tagline = "it's a nu dawn, it's a nu day, it's a nu shell for me, and i'm feeling good" # note on the sidebar
description = 'Discovering the rich capabilities of nushell for exploring structured data' # RSS feed description - keep brief
summary = '' # seo summary? unclear of usecase
aliases = [] # re-directs from moved content
tags = [] # content grouping tags
keywords = ["nushell", "nu", "nu shell", "xml"] # seo keywords
+++

## once upon a time in bohemia
i've been playing a ton of [kcd2](https://store.steampowered.com/app/1771300/Kingdom_Come_Deliverance_II/) lately. and by "lately" - i mean since December. it's rare for a game to hold my attention for so long - but here i am 250+ hours deep and still savoring every quest of it. There's so much wrong and unjust in this world, that its just comfortable to step into an equally unfair medieval bohemia and do my damnedest to be kind and set things right. call me boring but Good Henry is the only path for me.

anyways, i've started some dlc in here and now i have to play dice. a _lot_ of dice! so like a real gamer, i decided to hunt down some dice tables so i can make all this ~cheating~ ~gambling~ dice playing a bit easier to min/max. there's a bunch of out of date websites for this. there's also a reddit post which seems to be mostly up to date? so i did what any "totally normal" person would do and decided i wanted to extract the data from the game files and build a tui for it[^1].

2 months later - [lo and behold!](https://github.com/treyburn/farkle)
<img alt="a slick tui  for interatiuce dice tables in kcd2's farkle minigame" src="/images/farkle-demo.gif" width="700"/>

I know i'm 2 years late to the party - but for my ~cheap~ patient gamers out there, you can install this via:
```shell
go install go.treyburn.dev/farkle@latest
```

## nu problems...
so other than having claude vibe out yet another [bubbletea](https://github.com/charmbracelet/bubbletea) tui - how'd we get here?

well, i started poking around the kcd2 install path looking for things that looked like data files. my guess is that i would find something like json or a sqlite file. maybe with an obfuscated extension. after a little `fzf`-ing around - i found what i was looking for: `~/.steam/steam/steamapps/common/KingdomComeDeliverance2/Data/Tables.pak`.

but what the heck is a `.pak` file? we have the power!

```shell
file -i Tables.pak
#> Tables.pak: application/zip; charset=binary
```

as i suspected - it's just an alias for a `.zip` archive. did you know an `.xlsx` file is just a `.zip` archive of a bunch of `.xml` files? well - so is a `.pak`!

and within that archive is the exact file we are looking for - `item.xml`. but here's the tricky piece - it's got absolutely every item in the game in there! all i care about is dice. how do i even start to work with this giant ball of xml mud?

## ...require nu solutions
enter [nu](https://www.nushell.sh/book/installation.html).

a super helpful internet stranger answered my question to the void: 
> is there a jq-like tool for grepping around xml? seems like everything out there just converts elements to json - but what if i cared about both elements and attributes?
{.styled-quote}

> anything that has XPath support will take you a very long way. I personally use Nushell for that. it has everything for your data needs :)
{.styled-quote-2}

i had heard of nushell before. it's a shell but instead of the unix-style passing around data as strings - it passes everything around as tabular data. alright - let's try it.

so i downloaded nushell, took a brief bike-shedding detour to install [rocketship](https://starship.rs/presets/catppuccin-powerline) and give it a snazzy configuration - then we are off to the races!

```nushell
open ./data/item.xml | explore
```

and we're in! we can now interactive explore our file looking for the specific bits of data we care about then extract that as a 1 linter for data processing.

```nushell
open ./data/item.xml 
| get content.0.content 
| where tag == 'Die' 
| get attributes 
| select Id Name SideWeights SideValues

╭────┬──────────────────────────────────────┬─────────────────────────────────┬──────────────┬──────────────╮
│  # │                  Id                  │              Name               │ SideWeights  │  SideValues  │
├────┼──────────────────────────────────────┼─────────────────────────────────┼──────────────┼──────────────┤
│  0 │ 06d3757e-2882-4d75-99f9-1008a4e9d2d1 │ dieUnbalanced                   │ 3 4 1 1 2 1  │ 0 1 2 3 4 5  │
│  1 │ 11834cfd-bd67-41d8-8fe7-503f5076fa1d │ die_Matematikova                │ 4 5 6 7 1 1  │ 0 1 2 3 4 5  │
│  2 │ 1b1345f6-75c0-4477-b6d7-b9d73ec9d9f0 │ dieSkull                        │ 1 1 1 1 1 1  │ 0 1 2 3 4 5  │
│....│......................................│.................................│..............│..............│
│ 38 │ dccf7f80-e965-4666-957c-dbf975381fff │ dieTeeth_a                      │ 1 1 1 1 1 1  │ 0 1 2 3 4 5  │
│ 39 │ f8e3162a-dff1-4099-a60f-05be4e40f7ca │ prepadeni_dieBarn               │ 8 1 1 1 1 1  │ 0 1 2 3 4 5  │
│ 40 │ fd2e7345-5584-49d1-a0f9-e69c51d2bdf0 │ dieBlue                         │ 3 1 1 1 6 3  │ 0 1 2 3 4 5  │
├────┼──────────────────────────────────────┼─────────────────────────────────┼──────────────┼──────────────┤
│  # │                  Id                  │              Name               │ SideWeights  │  SideValues  │
╰────┴──────────────────────────────────────┴─────────────────────────────────┴──────────────┴──────────────╯
```

bingo! we've got out dice - but further exploration leads us to discover that the `item.xml` file isn't actually enough for our tui. we don't have the in-game name label used. just some internal name reference.

further exploration leads me to find a `~/.steam/steam/steamapps/common/KingdomComeDeliverance2/Localization/English_xml.pak` - which itself contains a `text_ui_items.xml` file - and within that file there's a mapping of the uuid to the `UIName`.

but how do I combine this? am I gonna have to do all this in my TUI at data load time? `nu` to the rescue yet again! turns out you can assign variables and join on fields - just like we're working with a baby database. we can even export the data back to json!

```nushell
let dice = (
    open ./data/item.xml
    | get content.0.content
    | where tag == 'Die'
    | get attributes
)

let die_names = ($dice | get UIName)

let ui_map = (
    open ./data/text_ui_items.xml
    | get content
    | get content
    | where {|row| $row.0.content.0.content in $die_names}
    | each {|row| {
        UIName: $row.0.content.0.content
        DisplayName: $row.2.content.0.content
      }}
)

$dice 
| join $ui_map UIName
| select Id SideWeights SideValues DisplayName
| save -f ./data/dice.json
```
 with that - I was fully in business to vibe out my tui. or so I thought. turns out there were duplicate dice entries - and some missing dice from the dlc.

no bother - `nu` back to the rescue. in that `tables.pak` was another `item__dlc.xml` with our dice and we can union those tables together with an `| append` call.

```nushell
# load our primary dice values
let dice = (
    open ./data/item.xml
    | get content.0.content
    | where tag == 'Die'
    | get attributes
)

# load the dlc from the dlc to include
let dlc_dice = (
    open ./data/item__dlc.xml
    | get content.0.content
    | where tag == 'Die'
    | get attributes
)

# Quest item flag is useful if we need to de-dupe identical dice - like in the case with Lucky Die.
let all_dice = ($dice | append $dlc_dice | default "false" IsQuestItem)
let die_names = ($all_dice | get UIName)

# pull our our pretty name values
let ui_map = (
    open ./data/text_ui_items.xml
    | get content
    | get content
    | where {|row| $row.0.content.0.content in $die_names}
    | each {|row| {
        UIName: $row.0.content.0.content
        DisplayName: $row.2.content.0.content
      }}
)

# and then put it all together
$all_dice
| join $ui_map UIName
# There are 2 instances of LuckyDie in the game. They are identical in states but one is a quest item and the other is not.
# Instead of having those dupliace - I choose to collapse them into a single result.
| group-by {|r| $"($r.DisplayName)|($r.Price)|($r.SideWeights | str trim)|($r.SideValues | str trim)"}
| values
| each {|g| $g | sort-by IsQuestItem | first}
| select Id SideWeights SideValues DisplayName
| save -f ./data/dice.json
```

and that's all we needed. put the whole thing together in some `.nu` scripts and now we even have a repeatable data processing pipeline that handles all the unzipping of the exact xml files we care about.

```nushell
#!/usr/bin/env nu

# extract.nu

# Pull the source xml files out of a KCD2 install and rebuild dice.json.
#
# The game ships its data as .pak files, which are plain zip archives. We only
# need two of them:
#
#   {game_dir}/Data/Tables.pak        -> Libs/Tables/item/item.xml, item__dlc.xml
#   {game_dir}/Localization/*_xml.pak -> text_ui_items.xml
#
# Requires `unzip` on PATH.
def main [
    game_dir: string # KCD2 install dir, e.g. ~/.steam/steam/steamapps/common/KingdomComeDeliverance2
    --data-dir: string # Directory to extract into. Defaults to this script's directory.
    --locale: string = "English" # Localization pak to read display names from.
] {
    let dir = ($data_dir | default $env.FILE_PWD)
    let game = ($game_dir | path expand)

    if not ($game | path exists) {
        error make {msg: $"no such directory: ($game)"}
    }
    if (which unzip | is-empty) {
        error make {msg: "unzip is required but was not found on PATH"}
    }

    # Tolerate being pointed at either the install root or the dir holding the pak.
    let tables = (find_pak $game ["Data/Table*.pak" "Table*.pak"])
    let localization = (find_pak $game [$"Localization/($locale)_xml.pak" $"($locale)_xml.pak"])

    print $"extracting from ($tables)"
    ^unzip -o -j $tables "*/item.xml" "*/item__dlc.xml" -d $dir | ignore

    print $"extracting from ($localization)"
    ^unzip -o -j $localization "*text_ui_items.xml" -d $dir | ignore

    nu ($env.FILE_PWD | path join "process.nu") --data-dir $dir
}

# Returns the first of the candidate globs (relative to root) that matches a file.
def find_pak [root: string, candidates: list<string>] {
    let hits = ($candidates | each {|c| glob ($root | path join $c)} | flatten)
    if ($hits | is-empty) {
        error make {msg: $"could not find ($candidates | str join ' or ') under ($root)"}
    }
    $hits | first
}
```

[^1]: _*puts clown makeup on*_ this was clearly a better use of my time than copy-pasta-ing the reddit post into a spreadsheet
