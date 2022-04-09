#! /usr/bin/env bash

if [[ "$1" == apache2* ]]; then
  WIKI_DIR="/var/www/html"
  SETTINGS_PATH="$WIKI_DIR/LocalSettings.php"
  uid="$(id -u)"
  gid="$(id -g)"
  if [ "$uid" = '0' ]; then
    user='www-data'
    group='www-data'
  fi

  if [ ! -s $SETTINGS_PATH ]; then
    if [ "$uid" = '0' ]; then
      # attempt to ensure that LocalSettings.php is owned by the run user
      # could be on a filesystem that doesn't allow chown (like some NFS setups)
      chown "$user:$group" $SETTINGS_PATH || true
    fi
  fi

  chown -R $user:$group $WIKI_DIR/cache
  chown -R $user:$group $WIKI_DIR/images
  chmod 755 $WIKI_DIR/images

  # If LocalSettings.php exists, then attempt to run the update.php maintenance
  # script. If already up to date, it won't do anything, otherwise it will
  # migrate the database if necessary on container startup. It also will
  # verify the database connection is working.
  if [ -e "LocalSettings.php" -a $MEDIAWIKI_UPDATE = true ]; then
    echo >&2 'info: Running maintenance/update.php';
    php $WIKI_DIR/maintenance/update.php --quick --conf $SETTINGS_PATH
  fi
fi

exec "$@"