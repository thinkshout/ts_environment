<?php

// Determine if we're in ~/Sites.
if (preg_match('#' . drush_server_home() . '/Sites/([^/]+)/?(web|docroot)?#', getcwd(), $path_matches)) {
  // Find the site name and web directory, if it exists.
  list($match, $site, $webdir) = $path_matches;

  // If web dir is beneath cwd, get its name and set it as the drush root.
  if (!$webdir) {
    foreach (array('web', 'docroot') as $dirname) {
      if (file_exists(getcwd() . "/$dirname")) {
        $webdir = $dirname;
        $options['root'] = getcwd() . "/$webdir";
        break;
      }
    } 
  }
  
  // Set uri for localhost.
  if ($webdir) {
    $options['uri'] = 'https://' . $webdir . '.' . $site . '.localhost';
  }
  else {
    $options['uri'] = 'https://' . $site . '.localhost';
  }
}

ini_set('memory_limit', '1G');
