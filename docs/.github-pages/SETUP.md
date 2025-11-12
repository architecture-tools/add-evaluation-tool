# GitHub Pages Setup

This documentation site is set up using Jekyll with the Just the Docs theme and is automatically published to GitHub Pages.

## What Was Set Up

1. **Jekyll Configuration** (`_config.yml`)
   - Just the Docs theme
   - Site metadata and settings
   - Search functionality enabled
   - GitHub edit links configured
   - Configured to include documentation from parent `docs/` directory

2. **GitHub Actions Workflow** (`.github/workflows/pages.yml`)
   - Automatically builds and deploys the site on push to main
   - Uses GitHub Pages deployment action
   - Builds from `docs/.github-pages/` directory

3. **Documentation Structure**
   - Landing page (`index.md`) in this folder
   - Navigation structure with parent/child relationships
   - Front matter added to all documentation files
   - All GitHub Pages files organized in this `.github-pages/` folder

4. **Dependencies** (`Gemfile`)
   - Jekyll 4.3
   - Just the Docs theme 0.8.0
   - Required plugins

## Enabling GitHub Pages

1. Go to your repository settings on GitHub
2. Navigate to "Pages" in the left sidebar
3. Under "Source", select "GitHub Actions" (not "Deploy from a branch")
4. The site will be available at: `https://architecture-tools.github.io/add-evaluation-tool/`

## Local Development

To preview the site locally:

```bash
cd docs/.github-pages
bundle install
bundle exec jekyll serve --source . --destination _site
```

Then open http://localhost:4000/add-evaluation-tool/ in your browser.

## Notes

- All GitHub Pages configuration and site files are in `docs/.github-pages/`
- Documentation content (sprints, architecture, requirements) remains in the parent `docs/` directory
- Jekyll includes documentation files from the parent directory
- The `baseurl` in `_config.yml` must match your repository name
- If your repository is in a different organization/user, update the `url` in `_config.yml`
- The GitHub Actions workflow will automatically deploy on every push to main

