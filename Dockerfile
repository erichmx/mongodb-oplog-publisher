FROM debian:wheezy

MAINTAINER George Haidar <ghaidar0@gmail.com>

RUN set -e; \
    apt-get update; \
    apt-get install -y build-essential curl; \
    curl -sL https://deb.nodesource.com/setup_6.x | bash -; \
    apt-get install -y mongodb-clients; \
    apt-get install -y git; \
    apt-get install -y nodejs; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

    RUN npm install -g forever
ENV REFRESHED 20170513 114912
    RUN npm install -g erichmx/mongodb-oplog-publisher

COPY docker-entrypoint.sh /docker-entrypoint.sh
#CMD ["forever", "--minUptime", "1000", "--spinSleepTime", "1000", "/usr/bin/mop"]
ENTRYPOINT ["bash","/docker-entrypoint.sh"]
