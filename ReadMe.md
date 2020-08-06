## About
Dockerized Postgres Database migration / replication using [bucardo](https://bucardo.org/)

## Pre-requisites
- git
- docker and docker-compose
- Bucardo requires superuser access on the source and target databases
- Bucardo cannot replicate the DDL, so a service must run its own migration tools on the target to create the schema, tables, etc

## Cloning and setup
- clone this repo
```bash
git clone git@github.com:danielmbaluka/bucardo-in-docker.git
```
- update the following environment variables in the Dockerfile
```bash
##------SOURCE DB--------
ENV SRC_HOST=<SRC_DB_HOST>
ENV SRC_PORT=<SRC_DB_PORT>
ENV SRC_DB=<SRC_DB_NAME>
ENV SRC_USER=<SRC_DB_USERNAME>
ENV SRC_PASS=<SRC_DB_PASSWORD>

##------TARGET DB--------
ENV DST_HOST=<DST_DB_HOST>
ENV DST_PORT=<DST_DB_PORT>
ENV DST_DB=<DST_DB_NAME>
ENV DST_USER=<DST_DB_USERNAME>
ENV DST_PASS=<DST_DB_PASSWORD>
```

- IMPORTANT!! - depending on the type of replication you want, update the flag `onetimecopy` line 39 on `configure.sh` script. The default value is `2` (fullcopy + delta). onetimecopy [reference](https://bucardo.org/onetimecopy/)


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
