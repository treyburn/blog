build:
    podman build -t hugo:latest .

init:
    podman run --rm -v .:/src hugo:latest new site blog

clean:
    podman run --rm -v .:/src -w /src/blog --entrypoint /bin/sh hugo:latest -c "rm -rf ./public"

blog CONTENT_PATH:
    podman run --rm -v .:/src -w /src/blog hugo:latest new posts/{{CONTENT_PATH}}

publish:
    podman run --rm -v .:/src -w /src/blog hugo:latest

# serve is intended for local dev. to see a preview of the production pages - check out the `preview` target
serve:
    podman run --rm -p 1313:1313 -v .:/src -w /src/blog hugo:latest serve -D --bind=0.0.0.0

preview:
    podman run --rm -p 1313:1313 -v .:/src -w /src/blog hugo:latest serve --bind=0.0.0.0

debug:
    podman run -ti -v .:/src --entrypoint /bin/sh hugo:latest
