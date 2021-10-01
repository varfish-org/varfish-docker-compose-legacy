# Run VarFish Server using Docker Compose

Detailed documentation can be found in the "Administrator's Manual" section of the [VarFish Server Manual](https://varfish-server.readthedocs.io/en/latest/).
You can get started in four (actually three) easy steps (given that you fulfill the requirements from below).

> - :interrobang: Questions? Need Help?
>   VarFish is academic software but we are happy to provide support on a best-effort manner.
>   Use the [issue tracker](https://github.com/bihealth/varfish-docker-compose/issues) or send an email to cubi-helpdesk@bihealth.de in case of any problems.
> - :factory: Bringing VarFish into "production"?
>   Feel free to contact us via cubi-helpdesk@bihealth.de in the case that you want to use VarFish beyond an evaluation.
>   We will try to assist you in your setup on a best-effort manner.

## Prerequisites

- Hardware:
    - Memory: 64 GB of RAM
    - CPU: 16 cores
    - Disk: 600+ GB of free and **fast** disk space
        - about ~500 GB for initial database (on compression enabled ZFS it will consume only 167GB)
        - on installation: ~100 GB for data package file
        - per exome: ~200MB
        - a few (~5) GB for the Docker images
- Operating System:
    - a modern Linux that is [supported by Docker](https://docs.docker.com/engine/install/#server)
    - outgoing HTTPS connections to the internet are allowed to download data and Docker images
    - server ports 80 and 443 are open and free on the host that run on this on
- Software:
    - [Docker](https://docs.docker.com/get-docker/)
    - [Docker Compose](https://docs.docker.com/compose/install/)

Notes:

- The typical main work is I/O-bound and *greatly* benefits from fast disks.
    - Using a single spinning disk is probably OK for trying out VarFish locally but won't be fun.
    - Use a disk array (RAID or ZFS/BTRFS) of spinning disks or ideally SSDs is recommended.
    - Don't forget that most file systems should not be filled above ~80-90% or you risk performance degradation.
    - CUBI is running a raidz2 array of 10 SSDs which gives plenty of performance.
- See the [VarFish Server Manual](https://varfish-server.readthedocs.io/en/latest/) for performance tuning tips and more details.

## Quickstart

See the "Administrator's Manual" section of the [VarFish Server Manual](https://varfish-server.readthedocs.io/en/latest/) for more details.

Optionally, fork this repository as a first step so you can track changes that you make using Git.

### 1. Get Scripts and Configuration

Clone this repository (or your clone) with the Docker Compose file.

```bash
$ git clone https://github.com/bihealth/varfish-docker-compose.git
$ cd varfish-docker-compose
```

### 2. Get Data

Download and extract the VarFish site data archive which contains everything you need to get started (the download is ~100GB of data).
This will create the `volumes` directory (500 GB of data, ZFS compression gives us 193 GB disk usage).

```bash
$ wget --no-check-certificate https://file-public.bihealth.org/transient/varfish/varfish-site-data-v0.22.2-20210212.tar.gz{,.sha256}
$ sha256sum --check varfish-site-data-v0.22.2-20210212.tar.gz.sha256
$ tar xf varfish-site-data-v0.22.2-20210212.tar.gz
$ ls volumes/
exomiser  jannovar  minio  postgres  redis  traefik
```

### 3. Bring up the site

First, create an installation-specific configuration file `.env` from `env.example`.
Make sure to set the `DJANGO_SECRET_KEY` variable to something random (a bash one-liner would be `tr -dc A-Za-z0-9 </dev/urandom | head -c 64 ; echo ''`).

```bash
$ cp .env env.example
$ $EDITOR .env
```

You can now bring up the site with Docker Compose.
The site will come up at your server and listen on ports 80 and 443 (make sure that the ports are open), you can access it at `https://<your-host>/` in your web browser.
This will create a lot of output and will not return you to your shell.
You can stop the servers with `Ctrl-C`.

```bash
$ docker-compose up
```

You can also use let Docker Compose run the containers in the background:

```bash
$ docker-compose up -d
Starting compose_exomiser-rest-prioritiser_1 ... done
Starting compose_jannovar_1                  ... done
Starting compose_traefik_1                   ... done
Starting compose_varfish-web_1               ... done
Starting compose_postgres_1                  ... done
Starting compose_redis_1                     ... done
Starting compose_minio_1                     ... done
Starting compose_varfish-celeryd-query_1     ... done
Starting compose_varfish-celeryd-default_1   ... done
Starting compose_varfish-celeryd-import_1    ... done
Starting compose_varfish-celerybeat_1        ... done
```

You can check that everything is running:

```bash
$ docker ps
3ec78fb9f12c   bihealth/varfish-server:0.22.1-0                            "docker-entrypoint.s…"   17 hours ago   Up 31 seconds   8080/tcp                                   compose_varfish-celeryd-import_1
313afb611ab1   bihealth/varfish-server:0.22.1-0                            "docker-entrypoint.s…"   17 hours ago   Up 30 seconds   8080/tcp                                   compose_varfish-celerybeat_1
4d865726e83b   bihealth/varfish-server:0.22.1-0                            "docker-entrypoint.s…"   17 hours ago   Up 31 seconds   8080/tcp                                   compose_varfish-celeryd-query_1
a5f90232c4da   bihealth/varfish-server:0.22.1-0                            "docker-entrypoint.s…"   17 hours ago   Up 31 seconds   8080/tcp                                   compose_varfish-celeryd-default_1
96cec7caebe4   bihealth/varfish-server:0.22.1-0                            "docker-entrypoint.s…"   17 hours ago   Up 33 seconds   8080/tcp                                   compose_varfish-web_1
8d1f310c9b48   postgres:12                                                 "docker-entrypoint.s…"   17 hours ago   Up 32 seconds   5432/tcp                                   compose_postgres_1
8f12e16e20cd   minio/minio                                                 "/usr/bin/docker-ent…"   17 hours ago   Up 32 seconds   9000/tcp                                   compose_minio_1
03e877ac11db   quay.io/biocontainers/jannovar-cli:0.33--0                  "jannovar -Xmx6G -Xm…"   17 hours ago   Up 33 seconds                                              compose_jannovar_1
6af09b819e59   traefik:v2.3.1                                              "/entrypoint.sh --pr…"   17 hours ago   Up 33 seconds   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   compose_traefik_1
514cb4386224   redis:6                                                     "docker-entrypoint.s…"   19 hours ago   Up 32 seconds   6379/tcp                                   compose_redis_1
5678b9e6797b   quay.io/biocontainers/exomiser-rest-prioritiser:12.1.0--1   "exomiser-rest-prior…"   19 hours ago   Up 34 seconds                                              compose_exomiser-rest-prioritiser_1
```

In the case of any error please report it to us via the Issue Tracker of this repository or email to `cubi-helpdesk@bihealth.de`.
Please include the full output as a text file attachment.

### 4. Use VarFish

Visit the website at `https://<your-host>/` and login with the account `root` and password `changeme`.
There will be a warning about self-signed certificates, see [TLS/SSL Certificates](#tlsssl-certificates) below on how to deal with this.
You can change it in the `Django Admin` (available from the menu with the little user icon on the top right).
You can also use the Django Administration interface to create new user records.

## Anatomy of this Repository

- The file `init.sh` performs some initialization to be done before starting the containers.
- The file `docker-compose.yml` contains the definition of the services required to run VarFish Server.
- The `config` directory contains files that are used for configuration:
    - `config/exomiser/application.properties` -- this file is blended into the Exomiser container for configuring it.
    - `config/postgres/postgresql.conf.orig` -- the VarFish site data archive comes with a preconfigured database, you can restore its configuration with this file if needed.
    - `config/traefik/certificates.toml` -- configuration for SSL/TLS setup
        - `/etc/traefik/tls/server.crt` and `server.key` -- place the SSL certificate and unencrypted private key here for custom SSL certificates
        - in the case of certificates from DFN (used by many German academic organizations), you will have to provide the full chain to the "Telekom" certificate in `server.crt`.

```bash
$ tree
.
├── config
│   ├── exomiser
│   │   └── application.properties
│   ├── postgres
│   │   └── postgresql.conf.orig
│   └── traefik
│       ├── certificates.toml
│       └── ssl
│           └── PLACE_TLS_FILES_HERE
├── docker-compose.yml
├── LICENSE
├── README.md
└── init.sh
```

## Configuration for the Impatient

Again, see the "Administrator's Manual" section of the [VarFish Server Manual](https://varfish-server.readthedocs.io/en/latest/) for more details.

When running with Docker Compose and the provided database files, VarFish comes preconfigured with sensible default settings and also contains some example datasets to try out.
There is only one things that you might want to tweak.

In the `docker-compose.yml` file you will find sections starting with `# BEGIN` and are followed by a token, e.g., `settings:testing`, `settings:production-provide-certificate`, and `settings:production-letsencrypt`.
You will have to decide for one of the following and make sure that the lines for your choice are not commented out while all the others should be (in the case of `OR` leave the section in for all `OR`-ed settings).

### TLS/SSL Certificates

The setup uses [traefik](https://traefik.io/) as a reverse proxy and must be reconfigured if you want to change the default behaviour of using self-signed certificates.

- `settings:testing` --
  By default (and as a fallback), traefik will use self-signed certificates that are recreated at every startup.
  These are probably fine for a test environment but you might want to change this to one of the below.
- `settings:production-provide-certificate` --
  You can provide your own certificates by placing them into ``config/traefik/tls/server.crt` and `server.key`.
  Make sure to provide the full certificate chain if needed (e.g., for DFN issued certificates).
- `settings:production-letsencrypt` --
  If your site is reachable from the internet then you can also use `settings:production-letsencrypt` which will use [letsencrypt](https://letsencrypt.org/) to obtain the certificates.
  NB: if you make your site reachable from the internet then you should be aware of the implications.
  VarFish is MIT licensed software which means that it comes "without any warranty of any kind", see the `LICENSE` file for details.

After changing the configuration, restart the site (e.g., with `docker-compose down && docker-compose up -d` if it is runnin in detached mode).

## Prioritization with CADD-scripts

See the section "Extra Services" in the [VarFish Server Manual](https://varfish-server.readthedocs.io/en/latest/) for instructions on how to enable this feature.

## TODO

- Document configuration for LDAP/AD integration.

## Maintainer Info

This section section is only interesting for maintainers of `varfish-docker-compose`.

Install the Github CLI ([see instructions](https://github.com/cli/cli#installation)), then login with `gh auth login`.

### Creating a new Release

Use `${varfish-server-version}-${build-version}` as the tag name for `varfish-docker-compose`.
This allows people to easily track if something changed here but the `varfish-server` version is the same.

1. Create a new entry in `HISTORY.md` and commit.
2. Create a new tag: `make tag TAG=vxx`.
3. Push the tag and release: `make release`.

## Branches

The **main** branch is the default branches and what you should track for deployment.
Individual versions are tagged here and it refers to stable versions only.

### Further Branches

- **dev** -- used for development, might jump around so don't track this
- **staging** -- used internally, might jump around, don't track this
- **production** -- used internally, might jump around, don't track this
- **kiosk** -- used for varfish-kiosk.bihealth.org, might jump around, don't track this
- **demo** -- used for varfish-demo.bihealth.org, might jump around, don't track this
