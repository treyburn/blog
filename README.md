# blog

More of a weedy garden plot than a blog.

## Getting Started

This project uses [just](https://github.com/casey/just) as a command runner and [podman](https://podman.io/) for containerization.

```shell
sudo apt install podman
sudo apt install just
```

### Building the Hugo Container

```bash
just build
```

This will build a container image with Hugo installed, tagged as `hugo:latest`.

### Initializing a New Hugo Site

```bash
just init
```

This will create a new Hugo site in the `blog` directory.

### Installing a Hugo Theme

To install a theme from [Hugo Themes](https://themes.gohugo.io/), copy the GitHub repository URL and run:

```bash
just theme <THEME_URL>
```

For example:

```bash
just theme https://github.com/theNewDynamic/gohugo-theme-ananke.git
```

This will:
1. Clone the theme repository into the `blog/themes` directory
2. Update the `blog/hugo.toml` file to use the theme

### Removing a Hugo Theme

To remove a previously installed theme, run:

```bash
just remove-theme <THEME_NAME>
```

For example:

```bash
just remove-theme hugo-theme-ananke
```

This will:
1. Remove the theme directory from `blog/themes`
2. Update the `blog/hugo.toml` file to remove the theme reference
