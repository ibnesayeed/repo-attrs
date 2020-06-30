# Repository Attributes Action

A GitHub Action to make various attributes of a repository available as output variables.
It is intended to be used with other actions such as [Create a Release](https://github.com/marketplace/actions/create-a-release) to suppliment them with information like contributors, files changed, pull requests, and commits.


## Inputs

Many attributes are extracted from the range of Git history `$tail..$head`.

### `head`

Most recent repo reference (empty default infers `HEAD` or a tag pointing to the head).

### `tail`

A prior repo reference to check for changes from (empty default infers the previous tag or the initial commit).

## Outputs

The action sets up various output variables to be utilized in any succeeding steps.

### `head`

Evaluated most recent repo reference.

### `tail`

Evaluated previous reference.

### `commits`

List of commits (hash and message).

### `prs`

List of pull requests (number and title).

### `files`

Summary of changed files.

### `contributors`

List of contributors (name and number of commits).


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
          # Utilize extracted attributes from the previous step
          body: |
            ## Changes in this Release

            History from `${{ steps.attrs.outputs.tail }}` to `${{ steps.attrs.outputs.head }}`

            ### Commits

            ${{ steps.attrs.outputs.commits }}

            ### Pull Requests

            ${{ steps.attrs.outputs.prs }}

            ### Contributors

            ${{ steps.attrs.outputs.contributors }}

            ### Files

            ```
            ${{ steps.attrs.outputs.files }}
            ```
```
