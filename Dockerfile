FROM node:6

MAINTAINER George Haidar <ghaidar0@gmail.com>

RUN set -e; \
    apt-get update; \
    apt-get install -y build-essential curl; \
    apt-get install -y mongodb-clients; \
    apt-get install -y git; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

    RUN npm install -g bson-ext forever mongo-oplog async coffee-script twelve antz
ENV REFRESHED 20170719 112623
    RUN npm install -g erichmx/mongodb-oplog-publisher

COPY docker-entrypoint.sh /docker-entrypoint.sh
#CMD ["forever", "--minUptime", "1000", "--spinSleepTime", "1000", "/usr/bin/mop"]
ENTRYPOINT ["bash","/docker-entrypoint.sh"]
