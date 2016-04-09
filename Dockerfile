FROM node:4

MAINTAINER Bakudankun <bakudankun@gmail.com>

ENV CROWI_VERSION v1.3.1
ENV NODE_ENV production

RUN apt-get update \
	&& apt-get install -y netcat libkrb5-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /usr/src/app \
	&& curl -SL https://github.com/crowi/crowi/archive/${CROWI_VERSION}.tar.gz \
	| tar -xz -C /usr/src/app --strip-components 1 \
	&& sed -i -e 's/bower /bower --allow-root /g' /usr/src/app/package.json

WORKDIR /usr/src/app

RUN npm install --unsafe-perm

COPY docker-entrypoint.sh /entrypoint.sh

VOLUME /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
