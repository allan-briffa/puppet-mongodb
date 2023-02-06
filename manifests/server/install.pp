# PRIVATE CLASS: do not call directly
class mongodb::server::install {
  $package_ensure        = $mongodb::server::package_ensure
  $package_name          = $mongodb::server::package_name
  $package_name_remove   = $mongodb::server::package_name_remove
  $dbpath                = $mongodb::server::dbpath
  $user                  = $mongodb::server::user
  $group                 = $mongodb::server::group

  case $package_ensure {
    true:     {
      $my_package_ensure = 'present'
      $file_ensure     = 'directory'
    }
    false:    {
      $my_package_ensure = 'absent'
      $file_ensure     = 'absent'
    }
    'absent': {
      $my_package_ensure = 'absent'
      $file_ensure     = 'absent'
    }
    'purged': {
      $my_package_ensure = 'purged'
      $file_ensure     = 'absent'
    }
    default:  {
      $my_package_ensure = $package_ensure
      $file_ensure     = 'present'
    }
  }
  user { 'mongo_user':
    ensure => present,
    name   => $mongodb::server::user,
  }
  -> package { 'mongodb_server_removal':
    ensure => absent,
    name   => $package_name_remove,
    tag    => 'mongodb_package',
  }
  -> package { 'mongodb_server':
    ensure => $my_package_ensure,
    name   => $package_name,
    tag    => 'mongodb_package',
  }
  exec { "Enforce ${dbpath} permissions":
        command => "chown ${user}:${group} ${dbpath}",
        refreshonly => true,
        subscribe => Package["mongodb_server"],
        path    => $::facts['path'],
      }
}
