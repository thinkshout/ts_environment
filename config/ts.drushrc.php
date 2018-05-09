<?php

// Determine if we're in ~/Sites.
if (preg_match('#' . drush_server_home() . '/Sites/([^/]+)/?(web)?#', getcwd(), $path_matches)) {
  // Find the site name and web directory, if it exists.
  list($match, $site, $web_in_cwd) = $path_matches;
  $web_in_subdir = file_exists(getcwd() . '/web');
  
  // Set uri for localhost.
  if ($web_in_cwd || $web_in_subdir) {
    $options['uri'] = 'https://web.' . $site . '.localhost';
  }
  else {
    $options['uri'] = 'https://' . $site . '.localhost';
  }
  
  // Set web root.
  if ($web_in_subdir) {
    $options['root'] = getcwd() . '/web';
  }
}
