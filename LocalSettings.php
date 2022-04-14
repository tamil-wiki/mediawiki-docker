<?php
#
# This file has the Default configuration which comes with MediaWiki.
# Do not directly edit this file.
# Edit the CustomSettings.php file for your need.
# All the configuration in this file configurable via environmental variable.

#TODO: This is temporary config for 1.37 version
error_reporting( 0 );

# This file was automatically generated by the MediaWiki 1.37.1
# installer. If you make manual changes, please keep track in case you
# need to recreate them later.
#
# See includes/DefaultSettings.php for all configurable settings
# and their default values, but don't forget to make changes in _this_
# file, not there.
#
# Further documentation for configuration settings may be found at:
# https://www.mediawiki.org/wiki/Manual:Configuration_settings

# Protect against web entry
if ( !defined( 'MEDIAWIKI' ) ) {
  exit;
}

function loadenv($envName, $default = "") {
  return getenv($envName) ? getenv($envName) : $default;
}

## Uncomment this to disable output compression
# $wgDisableOutputCompression = true;

$wgSitename = loadenv('MEDIAWIKI_SITE_NAME', "Tamil Wiki");
$wgMetaNamespace = loadenv('MEDIAWIKI_META_NAMESPACE', "Literary_Tamil_Wiki");

## The URL base path to the directory containing the wiki;
## defaults for all runtime URL paths are based off of this.
## For more information on customizing the URLs
## (like /w/index.php/Page_title to /wiki/Page_title) please see:
## https://www.mediawiki.org/wiki/Manual:Short_URL
$wgScriptPath = "";

## The protocol and server name to use in fully-qualified URLs
$wgServer = loadenv('MEDIAWIKI_SERVER_URL', "http://localhost");


## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;

## The URL paths to the logo.  Make sure you change this from the default,
## or else you'll overwrite your logo when you upgrade!
$wgLogos = [ '1x' => "$wgResourceBasePath/resources/assets/wiki.png" ];

## UPO means: this is also a user preference option

$wgEnableEmail = true;
$wgEnableUserEmail = true; # UPO

$wgEmergencyContact = loadenv("MEDIAWIKI_EMERGENCY_CONTACT", "apache@example.com");
$wgPasswordSender = loadenv("MEDIAWIKI_PASSWORD_SENDER","apache@example.com");

$wgEnotifUserTalk = false; # UPO
$wgEnotifWatchlist = false; # UPO
$wgEmailAuthentication = true;

## Database settings
$wgDBtype = loadenv('MEDIAWIKI_DB_TYPE', "mysql");
$wgDBserver = loadenv('MEDIAWIKI_DB_HOST', "database");
$wgDBname = loadenv('MEDIAWIKI_DB_NAME', "my_wiki");
$wgDBuser = loadenv('MEDIAWIKI_DB_USER', "root");
$wgDBpassword = loadenv('MEDIAWIKI_DB_PASSWORD', "secret");

# MySQL specific settings
$wgDBprefix = loadenv('MEDIAWIKI_DB_PREFIX');

# MySQL table options to use during installation or update
$wgDBTableOptions = loadenv('MEDIAWIKI_DB_TABLE_OPTIONS', "ENGINE=InnoDB, DEFAULT CHARSET=binary");

# Shared database table
# This has no effect unless $wgSharedDB is also set.
$wgSharedTables[] = "actor";

## Shared memory settings
#TODO: Defining string value in default is not working. So custom value from env will not work.
$mainCache = loadenv('MEDIAWIKI_MAIN_CACHE', CACHE_NONE);
$wgMainCacheType = constant($mainCache) ? constant($mainCache) : $mainCache;
switch ($wgMainCacheType) {
  case CACHE_MEMCACHED:
    $wgMemCachedServers = json_decode(loadenv('MEDIAWIKI_MEMCACHED_SERVERS', '[]'));
    break;
}

## To enable image uploads, make sure the 'images' directory
## is writable, then set this to true:
$wgEnableUploads = true;
$wgUseImageMagick = true;
$wgImageMagickConvertCommand = "/usr/bin/convert";

# InstantCommons allows wiki to use images from https://commons.wikimedia.org
$wgUseInstantCommons = false;

# Periodically send a pingback to https://www.mediawiki.org/ with basic data
# about this MediaWiki instance. The Wikimedia Foundation shares this data
# with MediaWiki developers to help guide future development efforts.
$wgPingback = false;

## If you use ImageMagick (or any other shell command) on a
## Linux server, this will need to be set to the name of an
## available UTF-8 locale. This should ideally be set to an English
## language locale so that the behaviour of C library functions will
## be consistent with typical installations. Use $wgLanguageCode to
## localise the wiki.
$wgShellLocale = "C.UTF-8";

# Site language code, should be one of the list in ./languages/data/Names.php
$wgLanguageCode = "en";

# Time zone
$wgLocaltimezone = loadenv('MEDIAWIKI_TIMEZONE', "Asia/Kolkata");

## Set $wgCacheDirectory to a writable directory on the web server
## to make your wiki go slightly faster. The directory should not
## be publicly accessible from the web.
#$wgCacheDirectory = "$IP/cache";

$wgSecretKey = loadenv('MEDIAWIKI_SECRET_KEY', null);

# Changing this will log out all existing sessions.
$wgAuthenticationTokenVersion = "1";

# Site upgrade key. Must be set to a string (default provided) to turn on the
# web installer while LocalSettings.php is in place
$wgUpgradeKey = loadenv('MEDIAWIKI_UPGRADE_KEY', null);

## For attaching licensing metadata to pages, and displaying an
## appropriate copyright notice / icon. GNU Free Documentation
## License and Creative Commons licenses are supported so far.
$wgRightsPage = ""; # Set to the title of a wiki page that describes your license/copyright
$wgRightsUrl = "https://creativecommons.org/licenses/by-sa/4.0/";
$wgRightsText = "Creative Commons Attribution-ShareAlike";
$wgRightsIcon = "$wgResourceBasePath/resources/assets/licenses/cc-by-sa.png";

# Path to the GNU diff3 utility. Used for conflict resolution.
$wgDiff3 = "/usr/bin/diff3";

## Default skin: you can change the default skin. Use the internal symbolic
## names, e.g. 'vector' or 'monobook':
$wgDefaultSkin = loadenv('MEDIAWIKI_DEFAULT_SKIN', "Timeless");

# Enabled skins.
# The following skins were automatically enabled:
wfLoadSkin( 'MonoBook' );
wfLoadSkin( 'Timeless' );
wfLoadSkin( 'Vector' );


# End of automatically generated settings.
# Add more configuration options below.

@include('CustomSettings.php');
