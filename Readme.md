# Nextcloud AIO on Truenas Scale Recipe

This guide summarizes the necessary steps to deploy Nextcloud AIO on Truenas Scale since it contains challenges compared to a basic Linux with Docker system.

## Motivations

  - Run Nextcloud AIO directly on top of docker on Truenas Scale. No VM overhead. It makes it easier to use harware acceleration if a GPU is present.
  - Benefits from ZFS Data Protection with the possibility to take snaphots and replicate the configurations, volumes and data. This can complete tbe Nextcloud AIO existing backup solution and make migration to a new machine easier when necessary.

## Requirements

  - You need Truenas Scale with version ElectricEel-24.10 or newer. Since this version, Scale ships with a working docker environnment instead of Kubernetes. It is also possible to deploy an application using Docker Compose, which is the chosen method described in this guide.
  - Please create a docker user if it does not exist. **UID MUST be 1001.**
  - This guide assumes you already have a valid SSL certificates to provide to the reverse proxy. I did not try this setup with acme challenge, but feedback and contributions are welcomed :).

## Challenges encountered with Truenas Scale

Truenas Scale comes with some specific behaviors compared to a default Debian system. In particular the following needs to be addressed to run Nextcloud AIO properly:

  - docker volume location: by default, Truenas Scale stores the volume data in it's internal volume directory at `/var/lib/docker/volumes`, making it challenging to backup and restore docker volumes. This setup creates bind mount inside the application folder, see the `volumes` section of the `compose.yml`.
  - Truenas Scale renames the networks by default, which causes trouble since Nextcloud AIO expect the network `nextcloud-aio` to attach the containers to it. The `networks` section in `compose.yml` solves this problem.

## How to deploy

  1. Create a Dataset that will contain your application compose, volume and caddy files. This dataset will be called `ConfigDataset` further in this guide. Clone this repo into this dataset.
  2. Run the script `bash setup_script.sh` to create the folder structure.
  3. Create a Dataset to be used as data directory with owner `www-data`. Please note the path of the Dataset and set it to the variable `NEXTCLOUD_DATADIR` in the `compose.yml` file. The dataset can be at the location of your choice. It will be called `DataDataset` in the rest of the guide.
  4. Check the `compose.yml` further. Look for TODO items, in particular adjust the certificates path for caddy.
  5. Add the application from the Truenas Scale UI: go to Apps > Discover Apps > Three dots next to Custom App > Install via YAML. Choose a name and use the following template in `Custom Config`:
  ```yaml
  include
    - /mnt/...yourPathTo/compose.yml
  ```
  Of course set the correct path that leads to your `compose.yml`.

  6. Click on save and wait for Truenas to download and start the aio container. This might take a few minutes based on your network connection and server speed.
  7. When the app shows started status from Apps UI, your nextcloud AIO interface should be available at http://yourTruenasIp:8080 (assuming you did not change the port in `compose.yml`)
  8. Your can now follow the normal steps to setup AIO
  9. Do not forget to forward port 443 to the machine/VM your system is running on, port 8443. 

## How to manage the installation

### Create snaphosts as backup

  1. Stop the nextcloud containers from the AIO interface.
  2. Stop AIO app from Truenas Scale UI.
  3. Take snapshots of ConfigDataset and DataDataset with the Truenas UI.
  4. Start AIO app from Truenas Scale UI.
  5. Your nextcloud should be running normally. YOu can try to update the containers from the AIO interface. If something goes wrong, you can use the rollback feature with the Truenas Snapshots you took previously, see the next section with details on how to restore.

### Restoring to a previous backup ###

  1. Stop the nextcloud containers from the AIO interface.
  2. Stop AIO app from Truenas Scale UI.
  3. Restore `ConfigDataset` and `DataDataset` at the desired snapshot using Truenas Scale UI. Please note: you must restore both datasets and use the corresponding versions you took together when you had stopped the containers during the section `Create snapshots as backup`. If both the config and data do not match, you nextcloud container might not start due to inconsistency between the database and the data folder.
  4. Start AIO app from Truenas Scale UI.
  5. Start the containers from the AIO interface

### Things to consider in your architecture

 - this guide assumes `ConfigDataset` and `DataDataset` are not on the same Pool, this can happen if your data is on hard drives while your applications pool is on SSDs. However this is you choice, since having both `ConfigDataset` and `DataDataset` can also make creation and restoration of ZFS snapthots much more easier with recursive mode.
 - Please test the backup and restore often, with more than one machine and before you populate a lot of data on your nextcloud, since the process is not as simple as taking a single backup of a VM for example.
