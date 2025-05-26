build:
    podman build -t hugo:latest .

init:
    podman run --rm -v .:/src hugo:latest new site blog

theme URL:
    podman run --rm -v ./src --entrypoint /bin/sh hugo:latest -c \
    "THEME_NAME=\$(basename \$(echo \"{{URL}}\" | sed 's/\.git$//')) && \
    git submodule add {{URL}} /src/blog/themes/\$THEME_NAME && \
    echo \"theme = \\\"\$THEME_NAME\\\"\" >> /src/blog/hugo.toml && \
    echo \"Theme '\$THEME_NAME' installed successfully!\""

remove-theme THEME_NAME:
    podman run --rm -v .:/src --entrypoint /bin/sh hugo:latest -c \
    "rm -rf /src/blog/themes/{{THEME_NAME}} && \
    sed -i '/theme = \"{{THEME_NAME}}\"/d' /src/blog/hugo.toml && \
    echo \"Theme '{{THEME_NAME}}' removed successfully!\""

blog CONTENT_PATH:
    podman run --rm -v .:/src -w /src/blog hugo:latest new posts/{{CONTENT_PATH}}

publish:
    podman run --rm -v .:/src -w /src/blog hugo:latest

debug:
    podman run -ti -v .:/src --entrypoint /bin/sh hugo:latest
