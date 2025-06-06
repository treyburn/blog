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

```shell
git submodule add <THEME_GIT_URL> blog/themes/<THEME>

```

For example:
```shell
git submodule add https://github.com/joeroe/risotto blog/themes/risotto
```

This will:
1. Properly create a git submodule link
2. Clone the theme repository into the `blog/themes` directory

After that you will need to update the `hugo.toml` file.

Unfortunately, there be dragons if you try to do this in a container. So just leave the git handling to the root os.

### Removing a Hugo Theme

To remove a previously installed theme, run:

```bash
git rm blog/theme/<THEME>
```

You'll also want to remove any refs from the `hugo.toml`

### Creating New Content

To create new content for your blog, run:

```bash
just blog <TITLE>
```

For example, to create a new blog post:

```bash
just blog "some new post"
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

### View the development site

To view the development site with live reload, run:

```shell
just serve
```

This will compile and serve your site with drafts included. Site available at: http://localhost:1313/

### Preview the production site

To view what the site will look like in production, run:

```shell
just preview
```

This will compile and serve the site as it will appear in production. IE no drafts included. Site available at: http://localhost:1313/

### Debugging with an Interactive Shell

To get an interactive shell inside the Hugo container for debugging purposes, run:

```bash
just debug
```

This will start a container with the current directory mounted and drop you into a shell, allowing you to explore the container environment and run Hugo commands manually.
