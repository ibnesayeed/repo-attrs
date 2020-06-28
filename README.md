# Repository Attributes Action

A GitHub Action to make various attributes of a repository available as output variables.
It is intended to be used with other actions such as [Create a Release](https://github.com/marketplace/actions/create-a-release) to suppliment them with information like contributors, files changed, pull requests, and commits.


## Inputs

Many attributes are extracted from a range of Git history `$tail..$head`.

### `head`

Most recent repo reference (default: `HEAD`).

### `tail`

A prior repo reference to check for chnages from (empty default infers the previous tag or the initial commit).

## Outputs

The action sets up various output variables to be utilized in any succeeding steps.

### `range`

Git range on which repo attrs were evaluated

### `commits`

List of commits (hashe and message)

### `prs`

List of pull requests (number and title)

### `files`

List of files (change summary)

### `contributors`

List of contributors (name and number of commits)


## Example Usage



```yml
on:
  push:
    tags:
      - '*'

name: Create Release

jobs:
  build:
    name: Create Release
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v2
        with:
          fetch-depth: 0 # This is important for the Git history
      - name: Extract Repo Attributes
        id: attrs # This is important for future referencing
        uses: ibnesayeed/repo-attrs@master
      - name: Create Release
        id: create_release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          # Utilize extracted attributes from teh previous step
          body: |
            # Changes in this Release
            History range `${{steps.attrs.outputs.range}}`
            ## Commits
            ${{steps.attrs.outputs.commits}}
            ## Commits
            ${{steps.attrs.outputs.commits}}
            ## PRs
            ${{steps.attrs.outputs.prs}}
            ## Files
            ```
            ${{steps.attrs.outputs.files}}
            ```
```
