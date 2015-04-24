# SimpleBackup

[![Gem Version](https://badge.fury.io/rb/simple_backup.svg)](http://badge.fury.io/rb/simple_backup)
[![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/tmaczukin/simple_backup/blob/development/LICENSE)

Backup tool with simple DSL definition.

**Tool is under heavy development and its API should be treat as unstable.**

## Why?

I needed an backup tool, that:

* works on \*nix systems,
* works in command line (I don't need GUI),
* has a simple declarative configuration mechanism,
* can store different backups in different places, with optional PGP encryption,
* is extendable (handling new sources, handling new backends, handling new filters etc.).

I haven't found that kind of backup tool so I decided to write my own. When I started this project I was also in the
process of ruby learning and this project seemed to be a good excersise for ruby programming.

Will this project be really usable and unusual? The history will judge :)

## Bugs, feedback

If you want to report a bug, please create [a GitHub issue](https://github.com/tmaczukin/simple_backup/issues/new).

If you need help, please create a issue or contact me (but I preffer issues). You can find my e-mail on my website,
or [tweet me](https://twitter.com/TomaszMaczukin).

## Contribution

If You want to contribute to the project, please feel free to fork it, create your feature/bug/hotfix branch and create
a new pull request. I am using ["git-flow"](http://nvie.com/posts/a-successful-git-branching-model/)-like workflow to work with
this repository:

1. There are two long-living branches: development and master. Master is always a "production" version. Development
   should always be in the "productino ready" state.
2. There will be no release branches.
3. All production versions are tagged and merged from master into development.

If you want to add new feature, please create "feature/..." branch from development. If you want to fix a non-critical
bug, please create "bug/..." branch from development. If you want to fix a "must-be-fixed-immediatly" bug, please
create "hotfix/..." branch from master.

SimpleBackup is versioned using [Semantic Versioning specification](http://semver.org/). Please follow the specification
when contributing - especially when creating a hotfixes (which always should be an a.b.X changes - so the backward
compatibility must be preserved).

If you want to help but you don't know what to do - look at TODO list. TODO list was moved to [Issues](https://github.com/tmaczukin/simple_backup/issues).

## License

This is free sofware licensed under MIT license. See LICENSE file.
