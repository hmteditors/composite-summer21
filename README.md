# composite-summer21


## Editing and data curation

This repository creates composite datasets from current editing work in five manuscripts.  See the [documentation](https://hmteditors.github.io/composite-summer21/), including automatically generated [summaries of current coverage](https://hmteditors.github.io/composite-summer21/coverage/).

## Data sets

The `data` directory has files in `cex` format.  See [details](https://hmteditors.github.io/composite-summer21/datasets/).

## Interactive notebooks

Pluto notebooks in the `simplenbs` directory only run with Pluto 0.15 or higher.  They use Pluto's new built-in package management, and should load significantly faster (at least after the first use) than traditional Pluto notebooks. (Currently, you need to `]add Pluto@main` before using Pluto since 0.15 is not yet registered on juliahub.)

Pluto notebooks in the `pluto` directory are identical to those in the `simplenbs` directory, but use Julia's generic `Pkg` manager to load libraries, and should run correctly in any version of Pluto.

See [details about the notebooks](https://hmteditors.github.io/composite-summer21/nbs/).