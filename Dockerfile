# Mention the required mediawiki version in build_args to upgrade / change the mediawiki
ARG MEDIAWIKI_VERSION=${MEDIAWIKI_VERSION:-1.37.1}
FROM mediawiki:${MEDIAWIKI_VERSION}

# Enable X-Forwarded-Host to work behind proxy
RUN set -eux; \
  a2enmod remoteip; \
  # Added local, k8s and docker default bridge CIDR's
  { \
    echo "RemoteIPHeader X-Forwarded-For"; \
    echo "RemoteIPTrustedProxy 127.0.0.0/8"; \
    echo "RemoteIPTrustedProxy 10.0.0.0/8"; \
    echo "RemoteIPTrustedProxy 172.16.0.0/12"; \
    echo "RemoteIPTrustedProxy 192.168.0.0/16"; \
    echo "RemoteIPTrustedProxy 169.254.0.0/16"; \
  } > "$APACHE_CONFDIR/conf-available/remoteip.conf"; \
  a2enconf remoteip; \
# https://github.com/docker-library/wordpress/issues/383#issuecomment-507886512
# (replace all instances of "%h" with "%a" in LogFormat)
	find /etc/apache2 -type f -name '*.conf' -exec sed -ri 's/([[:space:]]*LogFormat[[:space:]]+"[^"]*)%h([^"]*")/\1%a\2/g' '{}' +

VOLUME [ "/var/www/html/images", "/var/www/html/cache" ]

# Composer
RUN curl -L https://getcomposer.org/composer-2.phar > /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

ARG MEDIAWIKI_BRANCH=${MEDIAWIKI_BRANCH:-REL1_37}
ARG MEDIAWIKI_EXTENSIONS=${MEDIAWIKI_EXTENSIONS:-'MobileFrontend TemplateStyles BlueSpiceDashboards ConfirmAccount AccessControl Cargo CategoryLockdown GoogleLogin'}
# List of extensions need depencies install using composer.
ARG COMPOSER_INSTALL_EXTENSIONS="GoogleLogin "
ARG MEDIAWIKI_SKINS=${MEDIAWIKI_SKINS:-'MinervaNeue '}
ARG GERRIT_REPO="https://gerrit.wikimedia.org/r/mediawiki"
ARG EXTENSION_DIR="/var/www/html/extensions"
ARG SKIN_DIR="/var/www/html/extensions"

# Extensions
RUN for extension in $MEDIAWIKI_EXTENSIONS; do \
    git clone --depth 1 -b $MEDIAWIKI_BRANCH $GERRIT_REPO/extensions/$extension $EXTENSION_DIR/$extension; \
    done

# Skins
RUN for skin in $MEDIAWIKI_SKINS; do \
    git clone --depth 1 -b $MEDIAWIKI_BRANCH $GERRIT_REPO/skins/$skin $SKIN_DIR/$skin; \
    done

# Install composer dependencies for extensions
RUN for extension in $COMPOSER_INSTALL_EXTENSIONS; do \
  composer --working-dir=$EXTENSION_DIR/$extension install --no-dev; \
  done

RUN chown -R www-data:www-data $EXTENSION_DIR
RUN chown -R www-data:www-data $SKIN_DIR

COPY entrypoint.sh /entrypoint.sh
COPY check.php /check.php
COPY LocalSettings.php /var/www/html/LocalSettings.php
COPY CustomSettings.php /var/www/html/CustomSettings.php
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD ["apache2-foreground"]