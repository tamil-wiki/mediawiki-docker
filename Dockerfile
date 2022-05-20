# Mention the required mediawiki version in build_args to upgrade / change the mediawiki
ARG MEDIAWIKI_VERSION=${MEDIAWIKI_VERSION:-1.37.1}
# TODO: This has to be template based. The variant apache/fpm has to be passed as variable to template.
FROM mediawiki:${MEDIAWIKI_VERSION}-fpm

VOLUME [ "/var/www/html/images", "/var/www/html/cache", "/var/www/html/sitemap" ]

# Composer
RUN curl -L https://github.com/composer/composer/releases/download/2.1.14/composer.phar > /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer && apt update && apt-get install -y zip unzip && composer update

RUN pecl install redis && docker-php-ext-enable redis

ARG MEDIAWIKI_BRANCH=${MEDIAWIKI_BRANCH:-REL1_37}
ARG MEDIAWIKI_EXTENSIONS=${MEDIAWIKI_EXTENSIONS:-'MobileFrontend TemplateStyles BlueSpiceDashboards AccessControl Cargo WikiSEO Description2 MetaMaster ContactPage UserMerge'}
# List of extensions need depencies install using composer.
ARG COMPOSER_INSTALL_EXTENSIONS="GoogleLogin AWS"
ARG MEDIAWIKI_SKINS=${MEDIAWIKI_SKINS:-'MinervaNeue '}
ARG GERRIT_REPO="https://gerrit.wikimedia.org/r/mediawiki"
ARG EXTENSION_DIR="/var/www/html/extensions"
ARG SKIN_DIR="/var/www/html/extensions"

# Extensions
RUN for extension in $MEDIAWIKI_EXTENSIONS; do \
    git clone --depth 1 -b $MEDIAWIKI_BRANCH $GERRIT_REPO/extensions/$extension $EXTENSION_DIR/$extension; \
    done

RUN set -x; \
	cd $EXTENSION_DIR \
	# GoogleLogin
	&& git clone $GERRIT_REPO/extensions/GoogleLogin $EXTENSION_DIR/GoogleLogin \
	&& cd $EXTENSION_DIR/GoogleLogin \
	&& git checkout -q e424b28c32fbe6ef020b1a83e966bdf8ba71ca83 \
	# ConfirmAccount
	&& git clone $GERRIT_REPO/extensions/ConfirmAccount $EXTENSION_DIR/ConfirmAccount \
	&& cd $EXTENSION_DIR/ConfirmAccount \
	&& git checkout -q 2973d2c5aa14069130998ac72f480166101395ca \
	# CategoryLockdown
	&& git clone $GERRIT_REPO/extensions/CategoryLockdown $EXTENSION_DIR/CategoryLockdown \
	&& cd $EXTENSION_DIR/CategoryLockdown \
	&& git checkout -q d6d2c7917d3000d0bee7d328ad9df86fcd156eea \
	&& git clone https://github.com/edwardspec/mediawiki-aws-s3.git $EXTENSION_DIR/AWS \
	&& cd $EXTENSION_DIR/AWS \
	&& git checkout -q 301c5da5048067964a657ecce6b72e49916d03a7

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

CMD ["php-fpm"]
