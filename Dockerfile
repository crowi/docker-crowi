FROM node:latest

MAINTAINER Bakudankun <bakudankun@gmail.com>

ENV NODE_ENV production

RUN apt-get update \
	&& apt-get install -y libkrb5-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir /usr/src/app \
	&& curl -SL https://github.com/crowi/crowi/archive/master.tar.gz \
	| tar -xz -C /usr/src/app --strip-components 1 \
	&& cd /usr/src/app \
	&& npm install --unsafe-perm

RUN ln -s /data/uploads /usr/src/app/public/uploads

COPY docker-entrypoint.sh /entrypoint.sh

VOLUME /data
WORKDIR /usr/src/app
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
