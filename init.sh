#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $DIR

mkdir -p volumes/{exomiser,jannovar,minio/varfish-server,postgres/data,redis,traefik}
chmod -R ug=rwx,o=rx volumes/minio
chown -R 995:994 volumes/minio
