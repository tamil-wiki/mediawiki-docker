ARG MEDIAWIKI_VERSION=1.37.1
FROM mediawiki:${MEDIAWIKI_VERSION}

# TODO: Update apache configurations

#

VOLUME [ "/var/www/html/images", "/var/www/html/sites" ]

ARG MEDIAWIKI_BRANCH=REL1_37

ARG MEDIAWIKI_EXTENSIONS="MobileFrontend TemplateStyles BlueSpiceDashboards ConfirmAccount AccessControl Cargo CategoryLockdown"
ARG MEDIAWIKI_SKINS="MinervaNeue"
ARG GERRIT_REPO="https://gerrit.wikimedia.org/r/p/mediawiki"
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


# TODO: entrypoint