<?php
// To check the mediawiki already installed or not.
if ($_ENV['MEDIAWIKI_DB_TYPE'] == 'mysql') {
  $mysql = new mysqli($_ENV['MEDIAWIKI_DB_HOST'], $_ENV['MEDIAWIKI_DB_USER'], $_ENV['MEDIAWIKI_DB_PASSWORD'], '', (int) $_ENV['MEDIAWIKI_DB_PORT']);
  if ($mysql->connect_error) {
    file_put_contents('php://stderr', 'MySQL Connection Error: (' . $mysql->connect_errno . ') ' . $mysql->connect_error . "\n");
    exit(1);
  }

  if ($result = $mysql->query("SHOW TABLES FROM `" . $mysql->real_escape_string($_ENV['MEDIAWIKI_DB_NAME']) . "` LIKE 'content'")) {
    if($result->num_rows == 1) {
      file_put_contents('php://stdout', "Table exists");
    }
  } else {
    file_put_contents('php://stdout', "Table does not exists");
  }
  $mysql->close();
}