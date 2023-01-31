# @api private
class mongodb::client::params inherits mongodb::globals {
  $package_ensure = pick($mongodb::globals::version, 'present')
  $manage_package = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)
  $use_percona = pick($mongodb::globals::use_percona, 'false')
  $version_percona = pick($mongodb::globals::version_percona, 'present')

  if $manage_package {
    if $use_percona == false {
      $package_name = "mongodb-${mongodb::globals::edition}-shell"
    } else {
      $package_name = 'percona-server-mongodb-shell'
      $mongover = split($package_ensure, '[.]')
      $package_ensure = "${package_ensure}-${mongover[2]}.${facts['os']['distro']['codename']}"
    }
  } else {
    $package_name = $facts['os']['family'] ? {
      'Debian' => 'mongodb-clients',
      default  => 'mongodb',
    }
  }
}
