# PRIVATE CLASS: do not call directly
class mongodb::server::install {
  $package_ensure        = $mongodb::server::package_ensure
  $package_name          = $mongodb::server::package_name
  $package_name_remove   = $mongodb::server::package_name_remove
  $dbpath                = $mongodb::server::dbpath
  $user                  = $mongodb::server::user
  $group                 = $mongodb::server::group
  $use_percona           = $mongodb::server::use_percona

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
  -> if $use_percona==true {
      file_line { 'Percona log symlink dereference permissions':
        ensure             => present,
        path               => '/usr/bin/percona-server-mongodb-helper.sh',
        line               => 'chown -HR mongod:mongod /var/log/mongodb',
        match              => 'chown -R mongod:mongod /var/log/mongodb',
        append_on_no_match => false,
        subscribe          => Package['mongodb_server'],
      }
    } 
}
