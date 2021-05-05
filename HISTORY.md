# History / Changelog for varfish-docker-compose

`varfish-docker-compose` is versioned is tracking the `varfish-server` repository.
Not all `varfish-server` tags have a corresponding tag in `varfish-docker-compose`, though.

## v0.23.5-0

- Bumping to VarFish release v0.23.4.

## v0.23.4-0

- Bumping to VarFish release v0.23.4.
- Enabling beacon site feature by default (not active unless explicitely configured by admin).
- Fixing HTTP to HTTPS redirect.

## v0.23.0-0

- Adding missing `.env` file.
- Adding support for CADD annotation via [cadd-rest-api](https://github.com/bihealth/cadd-rest-api/).
  See [VarFish Server Manual](https://varfish-server.readthedocs.io/en/latest/) for installation instructions.
- Adding new required queues `maintenance` and `export`.

## v0.22.1-0

- First release of docker-compose.
