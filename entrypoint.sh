#! /usr/bin/env bash

if [[ "$1" == apache2* ]]; then
  uid="$(id -u)"
  gid="$(id -g)"
  if [ "$uid" = '0' ]; then
    user='www-data'
    group='www-data'
  fi

  if [ ! -s /var/www/html/LocalSettings.php ]; then
    if [ "$uid" = '0' ]; then
      # attempt to ensure that LocalSettings.php is owned by the run user
      # could be on a filesystem that doesn't allow chown (like some NFS setups)
      chown "$user:$group" /var/www/html/LocalSettings.php || true
    fi
  fi

  # Run update
fi

exec "$@"