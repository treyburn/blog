build:
    podman build -t hugo:latest .

init:
    podman run --rm -v .:/src hugo:latest new site blog

clean:
    podman run --rm -v .:/src -w /src/blog --entrypoint /bin/sh hugo:latest -c "rm -rf ./public"

blog TITLE:
    podman run --rm -v .:/src -w /src/blog hugo:latest new posts/$(date +%Y_%m_%d)_$(echo "{{TITLE}}" | tr ' ' '_' | tr -d "'\"").md

publish:
    podman run --rm -v .:/src -w /src/blog hugo:latest --minify

# serve is intended for local dev. to see a preview of the production pages - check out the `preview` target
serve:
    podman run --rm -p 1313:1313 -v .:/src -w /src/blog hugo:latest serve -D --minify --bind=0.0.0.0

preview:
    podman run --rm -p 1313:1313 -v .:/src -w /src/blog hugo:latest serve --minify --bind=0.0.0.0

# Optimize images in blog/static/images. Lossy for JPEGs, lossless for PNGs.
optimize:
    podman run --rm -v .:/src --entrypoint /bin/sh hugo:latest -c "jpegoptim --strip-all --max=95 /src/blog/static/images/*.jpg && optipng -o5 /src/blog/static/images/*.png"

debug:
    podman run -ti -v .:/src --entrypoint /bin/sh hugo:latest

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
