# GitHub Pages Documentation Site

This folder contains all files related to the GitHub Pages documentation site.

## Files

- `_config.yml` - Jekyll configuration
- `Gemfile` - Ruby dependencies
- `README.md` - This file (setup documentation)
- `SETUP.md` - Detailed setup instructions

## Structure

The Jekyll site is configured to:
- Use the parent `docs/` directory as the source (where `index.md` and all documentation lives)
- Keep only configuration files in this `.github-pages/` folder
- Build output goes to `_site/` in this folder

## Local Development

To preview the site locally:

```bash
cd docs
bundle install --gemfile .github-pages/Gemfile
bundle exec --gemfile .github-pages/Gemfile jekyll serve --source . --destination .github-pages/_site --config .github-pages/_config.yml
```

Then open http://localhost:4000/add-evaluation-tool/ in your browser.

## How It Works

1. Jekyll processes files from the parent `docs/` directory (source)
2. Configuration files (`_config.yml`, `Gemfile`) are in this `.github-pages/` folder
3. The GitHub Actions workflow builds using the config from this directory
4. The built site is deployed to GitHub Pages
