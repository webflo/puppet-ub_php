define ub_php($apc = true, $xdebug = true) {
  $version = $name
  include ub_php::fpm::config

  php::fpm { "${version}": }


  apache_php::fastcgi_handler { "${version}":
    php_version => $version,
    idle_timeout => '3600'
  }

  if $apc {
    php::extension::apc { "apc for ${version}":
      php => $version,
      config_template => "people/php/extensions/apc.ini.erb"
    }
  }

  if $xdebug {
    php::extension::xdebug { "xdebug for ${version}":
      php => $version
    }
  }
}

class ub_php::fpm::config {
  class { 'php::config':
    webserver => 'apache'
  }

  class { 'php::fpm::config':
    pm => 'static',
    pm_max_children => '5',
    request_terminate_timeout => 0
  }
}
