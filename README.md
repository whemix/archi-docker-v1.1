# Archi report builder (Docker image)

This Docker image provides a mechanism to generate HTML reports from an Archi model (using coArchi).

[Archi](https://www.archimatetool.com) is a visual modelling tool for enterprise architecture, using ArchiMate notation.

## Change Log

v1.1
- Forked from [archi-docker](https://github.com/users/dsample/packages/container/package/archi-docker)
- modified build-report.sh to output all possible report types
- modified to use Archi v4.9.1 and Co-Archi v0.8.1.202112061132


## Insallation

In order to build an HTML report, first you need to set up a repository with a coArchi-based model. This docker image does not provide the visual part of Archi, only a way to build a report, so you should install Archi locally to edit the model.

* [Download Archi][archi]
* [Download coArchi Plug-in][archi plugins]
  1. Open Archi
  2. From the `Help` menu, select `Manage Plug-ins`
  3. From the Plug-Ins dialog, select `Install New...` and locate the plugin file you downloaded
  4. Let Archi restart itself. The plugin should now be installed
* Configure the coArchi plug-in to with with this repository
  1. From the `Collaboration` menu, select `Import Remote Model to Workspace`
  2. Follow the instructions, using your usual method for accessing GitHub repositories (SSH/HTTPS) along with the relevant credentials.
     * If you use SSH, you may need to change the 'Identity file' path in Archi's preferences (if your key isn't stored in `~/.ssh/id_rsa`)
* Once the repository is in your workspace the `Collaboration` menu/sidebar can be used commit and push your changes to the repository.

> ⚠️ **Caution:** Archi can use branches, but they are not intended to work for merging changes (eg. Pull Requests).

## Usage

### Command line

```shell
docker run --rm -i -v "$(pwd)":/tmp/model -v "$(pwd)/html":/tmp/html ghcr.io/dsample/archi-docker:main
```

Explanation of the command line arguments above:

* `--rm`: Remove the container after it exits
* `-i`: Waits for the container to exit before continuing
* `-v "$(pwd)":/tmp/model`: Mounts the current working directory (where the coArchi model is located) within the container
* `-v "$(pwd)/html":/tmp/html`: Mounts the `html` directory within the current working directory into the container for the output to be saved in

### GitHub Actions Example

Using GitHub Actions an HTML report can be generated for the model upon each commit. Placing the resulting report into the `docs` directory also enables the use of GitHub Pages (which is available for private repositories).

```yaml
name: HTML Report

on:
  workflow_dispatch:
  push:
    branches: [ main ]
    paths: 
      - model

jobs:

  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout repo
      uses: actions/checkout@v2
    - name: Build the report
      run: >-
        docker run --rm -i
        -v "$(pwd)":/tmp/model
        -v "$(pwd)/docs":/tmp/html
        ghcr.io/whemix/archi-docker-v1.1:main
    - name: Commit the report
      run: |
        git config --global user.name "Archi"
        git add docs
        git diff-index --quiet HEAD || git commit -m 'Update report'
        git push
```

### Azure Pipeline Example

Using Azure Pipeline, generate interactive HTML and static reports in PDF, HTML, RTF, PPT, ODT, DOCX format for the model upon each commit. Resulting reports are placed into the `docs` directory of the model repository (in Azure Repos)

```yaml
trigger:
- master

pool:
  vmImage: ubuntu-latest

steps:
- checkout: self
  persistCredentials: true
- script: docker run --rm -i
        -v "$(pwd)":/tmp/model
        -v "$(pwd)/docs":/tmp/html
        ghcr.io/whemix/archi-docker-v1.1:main
  displayName: 'Build the report'

- script: |
        git config --global user.name "Archi"
        git add docs
        git diff-index --quiet HEAD || git commit -m '[skip ci] Update report'
        git push origin HEAD:master --force
  displayName: 'Commit the report'
```

[archi]: https://www.archimatetool.com/download/
[archi plugins]: https://www.archimatetool.com/plugins/
