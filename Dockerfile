# Mention the required mediawiki version in build_args to upgrade / change the mediawiki
ARG MEDIAWIKI_VERSION=${MEDIAWIKI_VERSION:-1.39}

#mw
# TODO: This has to be template based. The variant apache/fpm has to be passed as variable to template.
FROM mediawiki:${MEDIAWIKI_VERSION}-fpm

VOLUME [ "/var/www/html/images", "/var/www/html/cache", "/var/www/html/sitemap" ]

# Composer
RUN curl -L https://getcomposer.org/composer-2.phar > /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer

RUN pecl install redis && docker-php-ext-enable redis

# Have to specify here to work inside this FROM
ARG MEDIAWIKI_BRANCH=${MEDIAWIKI_BRANCH:-REL1_39}

ARG MEDIAWIKI_EXTENSIONS=${MEDIAWIKI_EXTENSIONS:-'MobileFrontend TemplateStyles AccessControl Cargo WikiSEO Description2 MetaMaster ContactPage UserMerge RevisionSlider LastUserLogin ExternalLinkConfirm intersection ContributionScores CreatePageUw Lockdown CategoryLockdown ConfirmAccount '}
# List of extensions need depencies install using composer.
ARG COMPOSER_INSTALL_EXTENSIONS=${COMPOSER_INSTALL_EXTENSIONS:-'GoogleLogin Elastica CirrusSearch '}
ARG MEDIAWIKI_SKINS=${MEDIAWIKI_SKINS:-'MinervaNeue '}
ARG GERRIT_REPO="https://gerrit.wikimedia.org/r/mediawiki"
ARG EXTENSION_DIR="/var/www/html/extensions"
ARG SKIN_DIR="/var/www/html/extensions"

# Extensions
RUN for extension in $MEDIAWIKI_EXTENSIONS; do \
    git clone --depth 1 --branch $MEDIAWIKI_BRANCH $GERRIT_REPO/extensions/$extension $EXTENSION_DIR/$extension; \
    done

RUN set -x; \
  cd $EXTENSION_DIR \
  # GoogleLogin
  && git clone $GERRIT_REPO/extensions/GoogleLogin $EXTENSION_DIR/GoogleLogin \
  && cd $EXTENSION_DIR/GoogleLogin \
  && git checkout ${MEDIAWIKI_BRANCH} \
  # TabberNeue - 2.4.0 - REL1_39 is not available. So used the 2.4.0 commit.
  && git clone https://github.com/StarCitizenTools/mediawiki-extensions-TabberNeue $EXTENSION_DIR/TabberNeue \
  && cd $EXTENSION_DIR/TabberNeue \
  && git checkout -q 57d34257927ee4edd56605173c4aebba6fc69e42 \
  # RottenLinks
  && git clone https://github.com/Miraheze/RottenLinks $EXTENSION_DIR/RottenLinks \
  && cd $EXTENSION_DIR/RottenLinks \
  && git checkout ${MEDIAWIKI_BRANCH} \
  # Moderation 1.8.9 - REL1_39 is not available. So used the latest master commit.
  && git clone https://github.com/edwardspec/mediawiki-moderation $EXTENSION_DIR/Moderation \
  && cd $EXTENSION_DIR/Moderation \
  && git checkout -q f14ac41e4d78a4a9c6d0978fc18a769d3b45e41e \
  # DynamicPageList3
  && git clone https://github.com/Universal-Omega/DynamicPageList3 $EXTENSION_DIR/DynamicPageList3 \
  && cd $EXTENSION_DIR/DynamicPageList3 \
  && git checkout ${MEDIAWIKI_BRANCH}
# Skins
RUN for skin in $MEDIAWIKI_SKINS; do \
    git clone --depth 1 --branch $MEDIAWIKI_BRANCH $GERRIT_REPO/skins/$skin $SKIN_DIR/$skin; \
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

CMD ["php-fpm"]
