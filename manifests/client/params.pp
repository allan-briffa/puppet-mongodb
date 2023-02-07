# @api private
class mongodb::client::params inherits mongodb::globals {
  $version = pick($mongodb::globals::version, 'present')
  $manage_package = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)
  $use_percona = pick($mongodb::globals::use_percona, 'false')
  $version_percona = pick($mongodb::globals::version_percona, 'present')

  if $manage_package {
    if $use_percona == false {
      $package_name = "mongodb-${mongodb::globals::edition}-shell"
      $package_name_remove = 'percona-server-mongodb-shell'
      $package_ensure = $version
    } else {
      $package_name = 'percona-server-mongodb-shell'
      $package_name_remove = "mongodb-${mongodb::globals::edition}-shell"
      $package_ensure = $version_percona
    }
  } else {
    $package_name = $facts['os']['family'] ? {
      'Debian' => 'mongodb-clients',
      default  => 'mongodb',
    }
  }
}
