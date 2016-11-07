FROM node:4

MAINTAINER Bakudankun <bakudankun@gmail.com>

ENV CROWI_VERSION v1.5.1
ENV NODE_ENV production

RUN apt-get update \
	&& apt-get install -y libkrb5-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN curl -SL -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh \
	&& chmod +x /usr/local/bin/wait-for-it.sh

RUN mkdir /usr/src/app \
	&& curl -SL https://github.com/crowi/crowi/archive/${CROWI_VERSION}.tar.gz \
	| tar -xz -C /usr/src/app --strip-components 1

WORKDIR /usr/src/app

RUN npm install --unsafe-perm

COPY docker-entrypoint.sh /entrypoint.sh

VOLUME /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
