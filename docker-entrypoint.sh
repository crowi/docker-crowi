#!/bin/bash
set -e

if [ "$1" == npm ]; then

	if nc -z db 27017 &> /dev/null ; then
		if [ -n "$MONGO_URI" ]; then
			echo >&2 'warning: both linked db container and MONGO_URI found'
			echo >&2 "  Connectiong to MONGO_URI ($MONGO_URI)"
			echo >&2 '  instead of linked MongoDB conatiner'
		fi
	elif [ -z "$MONGO_URI" ]; then
		echo >&2 'error: missing db container and MONGO_URI environment variables'
		echo >&2 '  Please --link some_mongdb_container:db or set an external db'
		echo >&2 '  with -e MONGO_URI=mongodb://hostname:port/some-crowi'
		exit 1
	fi
	export MONGO_URI=${MONGO_URI:-mongodb://db:27017/crowi}

	if nc -z redis 6379 &> /dev/null ; then
		if [ -n "$REDIS_URL" ]; then
			echo >&2 'warning: both linked redis container and REDIS_URL found'
			echo >&2 "  Connectiong to REDIS_URL ($REDIS_URL)"
			echo >&2 '  instead of linked Redis conatiner'
		else
			export REDIS_URL='redis://redis:6379/crowi'
		fi
	fi

	GIVEN_SEED=$PASSWORD_SEED
	PASSWORD_SEED=''
	if [ -f /data/config ]; then
		. /data/config
	fi
	if [ -n "$GIVEN_SEED" -a "$PASSWORD_SEED" -ne "$GIVEN_SEED" ]; then
		# A seed is given by command line, which is different from the content of /data/config.
		# Adopt the given seed and store it to /data/config.
		export PASSWORD_SEED=$GIVEN_SEED
		printf 'export PASSWORD_SEED="%q"' "$PASSWORD_SEED" >> /data/config
	elif [ -z "$PASSWORD_SEED" ]; then
		# Neither command line nor /data/config give PASSWORD_SEED.
		# Generate one and store it to /data/config.
		export PASSWORD_SEED=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`
		printf 'export PASSWORD_SEED="%q"' "$PASSWORD_SEED" >> /data/config
	else
		# Only /data/config gives PASSWORD_SEED, or given seed matches the content of /data/config.
		# The seed is already set to PASSWORD_SEED and /data/config, so nothing to do.
		:
	fi

fi

exec "$@"
