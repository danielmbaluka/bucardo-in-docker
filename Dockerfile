FROM ubuntu:20.04
RUN apt update -y

#  echo "Set disable_coredump false" >> /etc/sudo.conf disables some buggy sudo warnings
#  https://github.com/sudo-project/sudo/issues/42

RUN apt-get update && DEBIAN_FRONTEND=noninteractive \
    apt-get install -y postgresql-12 && \
    apt-get install -y sudo && \
    apt-get install -y wget && \
    apt-get install -y build-essential && \
    apt-get install -y libdbix-safe-perl && \
    apt-get install -y libdbd-pg-perl && \
    apt-get install -y gnupg && \
    apt-get install -y postgresql-plperl-12 && \
    echo "Set disable_coredump false" >> /etc/sudo.conf && \
    mkdir /var/run/bucardo

RUN apt update -y

ENV TZ=Africa/Nairobi
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Bucardo
RUN wget https://bucardo.org/downloads/Bucardo-5.6.0.tar.gz
RUN tar -xvf Bucardo-5.6.0.tar.gz
RUN cd Bucardo-5.6.0 && perl Makefile.PL && make install

RUN bucardo --version

# Copy pg_hba.conf (adds bucardo to trust list to access postgres over local connection
ADD pg_hba.conf /etc/postgresql/12/main/pg_hba.conf
RUN chown postgres:postgres /etc/postgresql/12/main/pg_hba.conf

RUN mkdir -p /src

COPY configure.sh /src
COPY monitor.sh /src
COPY bucardorc /src

RUN chmod +x /src/configure.sh
RUN chmod +x /src/monitor.sh

WORKDIR /src

#************** DATABASE CONNECTION SETTINGS **********#
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

# A few environment names
ENV VAR_SRC_DB=src_db
ENV VAR_DST_DB=dst_db
ENV VAR_HERD=mig_herd
ENV VAR_SYNC=mig_sync
ENV BUCARDO_DB_PASS=eix8Pipo5niegu2sie1i


#************ TABLES TO MIGRATE ************#
ENV MIGRATION_TABLES="<space separated list of tables to be replicated e.g products customers>"


