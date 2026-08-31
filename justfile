# The base image runs as its non-root `hugo` user, so rootless podman needs
# keep-id plus an explicit --user to map that back to us -- otherwise files it
# writes into the bind mount land owned by a subuid/subgid we don't own.
# /project is the image's declared workdir and volume.
hugo := "podman run --rm --userns=keep-id --user " + `id -u` + ":" + `id -g` + " -v .:/project"
blogdir := "-w /project/blog"
sh := "--entrypoint /bin/sh"

# Posts render GIFs at width="700", so anything wider is bytes the browser just
# throws away. --resize-fit-width only ever shrinks, so re-running is safe.
gifwidth := "700"
gifopts := "-O3 --lossy=30 --colors 64 --careful --loopcount=forever --resize-method catrom"

# List the available commands. First recipe, so bare `just` lands here too.
help:
    @just --list

# Build the hugo:latest container image the other recipes run in.
build:
    podman build -t hugo:latest .

# Scaffold a new Hugo site into ./blog. One-time bootstrap; already done.
init:
    {{hugo}} hugo:latest new site blog

# Delete the generated blog/public directory.
clean:
    {{hugo}} {{blogdir}} {{sh}} hugo:latest -c "rm -rf ./public"

# Create a new dated post. Usage: just blog "Nu Shell Nu Me"
blog TITLE:
    {{hugo}} {{blogdir}} hugo:latest new posts/$(date +%Y_%m_%d)_$(echo "{{TITLE}}" | tr ' ' '_' | tr -d "'\"").md

# Build the production site into blog/public.
publish:
    {{hugo}} {{blogdir}} hugo:latest --minify

# serve is intended for local dev. to see a preview of the production pages - check out the `preview` target
serve:
    {{hugo}} -p 1313:1313 {{blogdir}} hugo:latest serve -D --minify --bind=0.0.0.0

# Serve the production build (no drafts) on :1313.
preview:
    {{hugo}} -p 1313:1313 {{blogdir}} hugo:latest serve --minify --bind=0.0.0.0

# Optimize images in blog/static/images. Lossy for JPEGs and GIFs, lossless for PNGs.
optimize:
    {{hugo}} {{sh}} hugo:latest -c "jpegoptim --strip-all --max=95 /project/blog/static/images/*.jpg && optipng -o5 /project/blog/static/images/*.png && gifsicle -b {{gifopts}} --resize-fit-width {{gifwidth}} /project/blog/static/images/*.gif"

# Optimize a single JPEG (lossy). Usage: just optimize-jpeg blog/static/images/self.jpg
optimize-jpeg FILE:
    @just _optimize-one "{{FILE}}" 'jpegoptim --strip-all --max=95'

# Optimize a single PNG (lossless). Usage: just optimize-png blog/static/images/clown-bread.png
optimize-png FILE:
    @just _optimize-one "{{FILE}}" 'optipng -o5'

# Optimize a single GIF (lossy, downscaled). Usage: just optimize-gif blog/static/images/farkle-demo.gif [WIDTH]
optimize-gif FILE WIDTH=gifwidth:
    @just _optimize-one "{{FILE}}" 'gifsicle -b {{gifopts}} --resize-fit-width {{WIDTH}}'

# Shared plumbing: run TOOL against FILE inside the hugo image, reporting the size change.
_optimize-one FILE TOOL:
    #!/usr/bin/env bash
    set -euo pipefail
    file="{{FILE}}"
    if [ ! -f "$file" ]; then
        echo "No such file: $file" >&2
        exit 1
    fi
    rel=$(realpath --relative-to=. "$file")
    case "$rel" in
        ../*) echo "File must live inside the repo: $file" >&2; exit 1 ;;
    esac
    before=$(stat -c %s "$rel")
    {{hugo}} {{sh}} hugo:latest -c '{{TOOL}} "/project/'"$rel"'"'
    after=$(stat -c %s "$rel")
    echo "$rel: $before -> $after bytes ($(( (before - after) * 100 / before ))% smaller)"

# Drop into a shell inside the image, for poking at the toolchain.
debug:
    podman run -ti --rm --userns=keep-id -v .:/project {{sh}} hugo:latest

# Download a Font Awesome icon SVG. Usage: just icon "fa-brands fa-github"
icon FA_ICON:
    #!/usr/bin/env bash
    set -euo pipefail
    parts=({{FA_ICON}})
    if [ "${#parts[@]}" -ne 2 ]; then
        echo "Usage: just icon \"fa-brands fa-github\"" >&2
        echo "First part: fa-brands, fa-solid, or fa-regular" >&2
        exit 1
    fi
    style="${parts[0]#fa-}"
    name="${parts[1]#fa-}"
    url="https://raw.githubusercontent.com/FortAwesome/Font-Awesome/6.x/svgs/${style}/${name}.svg"
    dest="blog/static/icons/${name}.svg"
    echo "Downloading ${url} -> ${dest}"
    curl -fsSL "${url}" -o "${dest}"
    echo "Saved ${dest}"
