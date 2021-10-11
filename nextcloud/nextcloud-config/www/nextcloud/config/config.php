<?php
$CONFIG = array (
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.distributed' => '\\OC\\Memcache\\Redis', #add a distributed cache
  'filelocking.enabled' => true, #enable filelocking 
  'memcache.locking' => '\\OC\\Memcache\\Redis', #cache for filelocking
  'redis' => #details of redis cache
  array (
    'host' => 'nc_redis', #hostname of redis cache
    'port' => 6379, #port of redis cache
    'timeout' => 0.0, #timeout for redis cache
  ),
  'datadirectory' => '/data',
  'instanceid' => '<redacted>',
  'passwordsalt' => '<redacted>',
  'secret' => '<redacted>',
  'trusted_domains' => 
  array (
    0 => 'nextcloud.<domain>',
  ),
  'dbtype' => 'mysql',
  'version' => '22.2.0.2',
  'overwrite.cli.url' => 'https://nextcloud.<domain>',
  'dbname' => 'nextcloud',
  'dbhost' => 'nc_db:3306',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nc',
  'dbpassword' => '<redacted>',
  'installed' => true,
  'trusted_proxies' => #trusted proxy to only accept connections from that
  array (
    0 => 'swag', #add swag as trusted proxy 
  ),
  'overwritehost' => 'nextcloud.<domain>', #hostname of proxy
  'overwriteprotocol' => 'https', #protocol of proxy
  'default_language' => 'en', #default language: english
  'default_locale' => 'en_IN', #default locale: english_india
  'default_phone_region' => 'IN', #default phone: india
);
