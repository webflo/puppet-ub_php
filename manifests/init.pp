define ub_php (
  $apc = true,
  $intl = true,
  $mcrypt = true,
  $xdebug = true,
  $mailcatcher = true,
  $ensure = present,
) {
  $version = $name
  include ub_php::fpm::config
  include php::composer

  apache_php::fastcgi_handler { "${version}":
    php_version => $version,
    idle_timeout => '3600'
  }

  if $ensure == "present" {
    php::fpm { "${version}": }

   if $apc {
      php::extension::apc { "apc for ${version}":
        php => $version,
        config_template => "people/php/extensions/apc.ini.erb"
      }
    }

    if $intl {
      php::extension::intl { "intl for ${version}":
        php => $version,
        version => "3.0.0"
      }
    }

    if $mcrypt {
      php::extension::mcrypt { "mcrypt for ${version}":
        php => $version,
      }
    }

    if $xdebug {
      php::extension::xdebug { "xdebug for ${version}":
        php => $version,
        version => "2.2.3"
      }
    }

    if $mailcatcher {
      include mailcatcher
      file { "/opt/boxen/config/php/${version}/conf.d/10-mailcatcher.ini":
        ensure => "file",
        content => template('ub_php/mailcatcher.ini.erb'),
        notify  => Service["dev.php-fpm.${version}"]
      }
    }

    file { "/opt/boxen/config/php/${version}/conf.d/00-default.ini":
      ensure => 'link',
      target => "/Users/${::boxen_user}/.boxen/config/php/default.ini",
    }

    file { "/opt/boxen/config/php/${version}/conf.d/10-version.ini":
      ensure => 'link',
      target => "/Users/${::boxen_user}/.boxen/config/php/php-${version}.ini",
    }
  }
  elsif ($ensure == "absent") {
    php::version { "${version}":
      ensure => "absent",
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
