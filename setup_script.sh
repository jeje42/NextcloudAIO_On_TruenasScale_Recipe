#!/bin/bash

#Create the folders for caddy
mkdir -p caddy/{config,data,sites}
chown -Rv docker caddy

# Create the folders for the docker volumes
mkdir -p volumes/{nextcloud_aio_apache,nextcloud_aio_clamav,nextcloud_aio_database_dump,nextcloud_aio_mastercontainer,nextcloud_aio_onlyoffice,nextcloud_aio_talk_recording,nextcloud_aio_calcardbackup,nextcloud_aio_database,nextcloud_aio_elasticsearch,nextcloud_aio_nextcloud,nextcloud_aio_redis}
chown -Rv docker volumes
