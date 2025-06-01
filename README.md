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

### Creating New Content

To create new content for your blog, run:

```bash
just blog <CONTENT_PATH>
```

For example, to create a new blog post:

```bash
just blog some-new-post.md
```

This will:
1. Create a new content file at the specified path in the `blog/content` directory
2. Use the default archetype template to populate the file with frontmatter

### Publishing Your Site

To build your site for production, run:

```bash
just publish
```

This will generate your static site in the `blog/public` directory, ready for deployment.

### Debugging with an Interactive Shell

To get an interactive shell inside the Hugo container for debugging purposes, run:

```bash
just debug
```

This will start a container with the current directory mounted and drop you into a shell, allowing you to explore the container environment and run Hugo commands manually.
