FROM node:latest

MAINTAINER Bakudankun <bakudankun@gmail.com>

RUN apt-get update \
	&& apt-get install -y libkrb5-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& npm install -g https://github.com/crowi/crowi.git

WORKDIR /usr/local/lib/node_modules/crowi

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
