---
layout: post
title: "commit id updated"
date: 2026-06-07 02:00:31 +1000
---

I have found how to add the commit id:

To display the latest Git commit hash on a GitHub Pages site using Jekyll, you cannot query Git directly at runtime because GitHub Pages serves static HTML. Your current implementation uses `{{ site.data['hash'] }}`, which is a great approach, but it requires a `hash.yml` or `hash.json` file to exist in your site's `_data` folder.

Since GitHub Pages builds your site automatically when you push, you can use a **GitHub Action** to automatically fetch the latest commit hash, write it to your Jekyll `_data` folder, and deploy the site.

Here is how you can set this up:

### Step 1: Create a GitHub Actions Workflow

If you don't already have a custom workflow, you will need to create one. In your GitHub repository, create a new file at this exact path:
`.github/workflows/jekyll-gh-pages.yml`

### Step 2: Add the Workflow Configuration

Paste the following configuration into your new `jekyll-gh-pages.yml` file. This workflow intercepts the build process, writes the latest short commit SHA into `_data/hash.yml`, and then builds/deploys the site to GitHub Pages.

```yaml
name: Deploy Jekyll site with Git Hash

on:
  push:
    branches: ["main"] # Change to "master" if your default branch is master

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

# Allow only one concurrent deployment
concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # Fetches all history so the commit hash is available

      - name: Setup Pages
        uses: actions/configure-pages@v4

      # --- CRITICAL STEP: Write the commit hash to Jekyll's data folder ---
      - name: Save Git Commit Hash to Jekyll Data
        run: |
          mkdir -p _data
          echo "short_sha: $(git rev-parse --short HEAD)" > _data/hash.yml

      - name: Build with Jekyll
        uses: actions/jekyll-build-pages@v1
        with:
          source: ./
          destination: ./_site

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3

  deploy:
    environment:
      name: github-pages
      url: ${{ steps:deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4

```

### Step 3: Update your Footer Code

Because the GitHub Action writes the hash into `_data/hash.yml` under the key `short_sha`, you just need to adjust your Jekyll Liquid tag slightly to target `short_sha`.

Update your footer to look like this:

```html
<footer>
    <p>&copy; 2023 Your Name. All rights reserved.</p>
    <p>Git Commit: {{ site.data.hash.short_sha }} </p>
    <script>
        if (localStorage.pageViews) {
            localStorage.pageViews = Number(localStorage.pageViews) + 1;
        } else {
            localStorage.pageViews = 1;
        }
        document.write("<p>Page Views: " + localStorage.pageViews + "</p>");
    </script>
</footer>

```

### Step 4: Configure GitHub Repository Settings

For this custom GitHub Action workflow to take effect and publish your site, you need to tell GitHub to build from Actions instead of the classic branch method:

1. Go to your repository on GitHub.
2. Click on **Settings** (the gear icon).
3. In the left sidebar, click on **Pages**.
4. Under **Build and deployment**, look for **Source**.
5. Change the dropdown menu from *Deploy from a branch* to **GitHub Actions**.

Once you commit and push these changes, GitHub Actions will trigger a build. It will dynamically generate `_data/hash.yml` on the fly, compile your Jekyll site, and your footer will successfully show the latest commit ID.
