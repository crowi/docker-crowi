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

	# Generate and store PASSWORD_SEED environment varaiable if not available
	if [ -f /data/config ]; then
		. /data/config
	fi
	if [ -z "$PASSWORD_SEED" ]; then
		export PASSWORD_SEED=`head -c1M /dev/urandom | sha1sum | cut -d' ' -f1`
		echo "export PASSWORD_SEED=$PASSWORD_SEED" >> /data/config
	fi

fi

exec "$@"
