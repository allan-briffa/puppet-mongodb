# PRIVATE CLASS: do not call directly
class mongodb::server::install {
  $package_ensure        = $mongodb::server::package_ensure
  $package_name          = $mongodb::server::package_name
  $package_name_remove   = $mongodb::server::package_name_remove
  $use_percona           = $mongodb::server::use_percona
  $logpath               = $mongodb::server::logpath,
  $user                  = $mongodb::server::user,
  $group                 = $mongodb::server::group,

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
  -> if $use_percona == true {
    file { "${logpath}/mongod.stderr":
      owner => $user,
      group => $group,
      mode  => '0644',
    }
    -> file { "${logpath}/mongod.stdout":
      owner => $user,
      group => $group,
      mode  => '0644',
    }
  }
}
