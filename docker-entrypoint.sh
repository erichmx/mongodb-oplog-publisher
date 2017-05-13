echo Starting mongodb-oplog-publisher

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	echo "Reading ${var}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

while read i; do file_env $i; done < <(env | grep _FILE= | sed -n 's/\(.*\)_FILE=.*/\1/p')
# SECURITY HOLE PRINTING ENV AFTER LOADING SECRETS, DON'T DO IT!! printenv

mongo --version
forever --minUptime 1000 --spinSleepTime 1000 /usr/local/bin/mop
