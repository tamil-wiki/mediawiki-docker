#! /usr/bin/env bash

: ${MEDIAWIKI_SITE_NAME:=MediaWiki}
: ${MEDIAWIKI_SITE_LANG:=en}
: ${MEDIAWIKI_ADMIN_USER:=admin}
: ${MEDIAWIKI_DB_TYPE:=mysql}
: ${MEDIAWIKI_ENABLE_SSL:=false}
: ${MEDIAWIKI_UPDATE:=false}
: ${MEDIAWIKI_SERVER_URL:=http://localhost}

if [[ "$1" == apache2* ]] || [ "$1" = 'php-fpm' ]; then
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

  isMediawikiInstalled=false
  phpOutput=$(php /check.php)

  if [ "$phpOutput" = "Table exists" ]; then
    isMediawikiInstalled=true
  fi

  # If the container start first time, then install the mediawiki
  if [ $isMediawikiInstalled = false ]; then
    mv $SETTINGS_PATH /tmp/LocalSettings.php.bak
    echo >&2 'info: Running maintenance/install.php';
    mkdir -p $WIKI_DIR/tmp/
    php maintenance/install.php \
      --confpath $WIKI_DIR \
      --dbname "$MEDIAWIKI_DB_NAME" \
      --dbport "$MEDIAWIKI_DB_PORT" \
      --dbserver "$MEDIAWIKI_DB_HOST" \
      --dbtype "$MEDIAWIKI_DB_TYPE" \
      --dbuser "$MEDIAWIKI_DB_USER" \
      --dbpass "$MEDIAWIKI_DB_PASSWORD" \
      --installdbuser "$MEDIAWIKI_DB_USER" \
      --installdbpass "$MEDIAWIKI_DB_PASSWORD" \
      --server "$MEDIAWIKI_SERVER_URL" \
      --scriptpath "" \
      --lang "$MEDIAWIKI_SITE_LANG" \
      --pass "$MEDIAWIKI_ADMIN_PASS" \
      "$MEDIAWIKI_SITE_NAME" \
      "$MEDIAWIKI_ADMIN_USER"

    mv /tmp/LocalSettings.php.bak $SETTINGS_PATH
    # Run update.php as extensions need to create tables
    # This condition is to avoid running update.php multiple times.
    if [[ -z $MEDIAWIKI_UPDATE || $MEDIAWIKI_UPDATE != true ]]; then
      php $WIKI_DIR/maintenance/update.php --quick --conf $SETTINGS_PATH
    fi
  fi

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