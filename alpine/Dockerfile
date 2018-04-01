FROM node:6-alpine

ENV CROWI_VERSION v1.6.3
ENV NODE_ENV production

RUN set -ex; \
	apk --no-cache add openssl; \
	wget -O /usr/local/bin/wait-for https://raw.githubusercontent.com/eficode/wait-for/master/wait-for; \
	chmod +x /usr/local/bin/wait-for; \
	mkdir /usr/src; \
	wget -O - https://github.com/crowi/crowi/archive/${CROWI_VERSION}.tar.gz \
		| tar -xz -C /usr/src/; \
	mv /usr/src/crowi-${CROWI_VERSION#v} /usr/src/app; \
	apk --no-cache del openssl

WORKDIR /usr/src/app

RUN npm install --unsafe-perm

COPY docker-entrypoint.sh /entrypoint.sh

VOLUME /data
ENTRYPOINT ["/entrypoint.sh"]
CMD ["npm", "start"]
