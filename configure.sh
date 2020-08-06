#!/bin/bash

# Ensure postgresql is running
service postgresql start


# Create bucardo database

sudo -u postgres psql -c "create database bucardo;"
sudo -u postgres psql -c "CREATE ROLE bucardo LOGIN SUPERUSER PASSWORD '$BUCARDO_DB_PASS';"
sudo -u postgres psql -c "grant all privileges on database bucardo to bucardo;"

# echo bucardo pass for convenience
echo "bucardo pass is $BUCARDO_DB_PASS"

# Finish the Bucardo installation:
bucardo install --bucardorc /src/bucardorc install --batch

# should show a config
bucardo show all

# Create the source and target database objects:
bucardo add db $VAR_SRC_DB host=$SRC_HOST dbname=$SRC_DB user=$SRC_USER pass=$SRC_PASS
bucardo add db $VAR_DST_DB host=$DST_HOST dbname=$DST_DB user=$DST_USER pass=$DST_PASS

# Tell Bucardo about the tables that we want to replicate, and which database to use as the source:
# postgres will assume a schema of "public", if you have a different schema
# each table needs to be prefixed with that

bucardo add tables $MIGRATION_TABLES db=$VAR_SRC_DB

# Add the tables to a “herd” (like a replication group I guess?):
bucardo add herd $VAR_HERD $MIGRATION_TABLES --verbose

# Create the sync object. For some reason, here the herd object is known as a relgroup.
# onetimecopy=2 is important - this will delete everything in the target first, do a full replication,
# then switch to replicating the deltas (equivalent to DMS's full-load and cdc option):
# Also disable strict checking
bucardo add sync $VAR_SYNC relgroup=$VAR_HERD dbs=$VAR_SRC_DB:source,$VAR_DST_DB:target onetimecopy=0 strict_checking=false

# It’s useful to set logging more verbose than default:
bucardo set log_showlevel=1
bucardo set log_level=debug #or "verbose"

echo "To start replication, run bucardo start"
