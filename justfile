build:
    podman build -t hugo:latest .

init:
    podman run --rm -v $(pwd):/src hugo:latest new site blog

theme URL:
    podman run --rm -v $(pwd):/src --entrypoint /bin/sh hugo:latest -c \
    "THEME_NAME=\$(basename \$(echo \"{{URL}}\" | sed 's/\.git$//')) && \
    git clone {{URL}} /src/blog/themes/\$THEME_NAME && \
    echo \"theme = \\\"\$THEME_NAME\\\"\" >> /src/blog/hugo.toml && \
    echo \"Theme '\$THEME_NAME' installed successfully!\""

remove-theme THEME_NAME:
    podman run --rm -v $(pwd):/src --entrypoint /bin/sh hugo:latest -c \
    "rm -rf /src/blog/themes/{{THEME_NAME}} && \
    sed -i '/theme = \"{{THEME_NAME}}\"/d' /src/blog/hugo.toml && \
    echo \"Theme '{{THEME_NAME}}' removed successfully!\""
