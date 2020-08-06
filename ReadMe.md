## About
Dockerized Postgres Database migration / replication using [bucardo](https://bucardo.org/)

## Pre-requisites
- git
- docker
- Bucardo requires superuser access on the source and target databases
- Bucardo cannot replicate the DDL, so a service must run its own migration tools on the target to create the schema, tables, etc

## Cloning
``git clone <>``

## Building and Running the bucardo container
```bash
docker-compose build --force-rm --no-cache ubuntu
docker-compose run -d ubuntu bash
```

### docker exec into the container and run the bucardo installation and configuration script
```bash
docker-compose ps # and take note of the container id
docker exec -it <container id> bash
./configure.sh
```

## Replication
Once setup is completed, run `bucardo status` inside the container and confirm you can see your sync. To start the sync run `bucardo start`
Note: This will start the replication process

## Monitoring
- logs: `tail -f /var/log/bucardo/log.bucardo`
- check replication status: `bucardo status` or `bucardo status <sync>`
- incase replication / sync stalls, run `bucardo reload sync` or `bucardo restart`
