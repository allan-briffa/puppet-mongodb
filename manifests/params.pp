# PRIVATE CLASS: do not use directly
class mongodb::params inherits mongodb::globals {
  $ensure                = true
  $dbpath                = '/var/lib/mongodb'
  $bind_ip               = pick($mongodb::globals::bind_ip, ['127.0.0.1'])
  $ipv6                  = undef
  $service_manage        = pick($mongodb::globals::mongod_service_manage, true)
  $service_enable        = pick($mongodb::globals::service_enable, true)
  $service_ensure        = pick($mongodb::globals::service_ensure, 'running')
  $service_status        = $mongodb::globals::service_status
  $restart               = true
  $create_admin          = false
  $admin_username        = 'admin'
  $admin_roles           = [
    'userAdmin', 'readWrite', 'dbAdmin', 'dbAdminAnyDatabase', 'readAnyDatabase',
    'readWriteAnyDatabase', 'userAdminAnyDatabase', 'clusterAdmin',
    'clusterManager', 'clusterMonitor', 'hostManager', 'root', 'restore',
  ]
  $handle_creds          = true
  $store_creds           = false
  $rcfile                = "${::root_home}/.mongorc.js"
  $dbpath_fix            = false

  $manage_package        = pick($mongodb::globals::manage_package, $mongodb::globals::manage_package_repo, false)
  $use_percona           = pick($mongodb::globals::use_percona, false)
  $pidfilemode           = pick($mongodb::globals::pidfilemode, '0644')
  $manage_pidfile        = pick($mongodb::globals::manage_pidfile, true)

  $version               = $mongodb::globals::version
  $mongover              = split($version, '[.]')

  $config_data           = undef

  if $version {
    $package_ensure        = $use_percona ? {
      true    => "${version}-${mongover[2]}.${facts['os']['distro']['codename']}",
      default => $version,
    }
    $package_ensure_mongos = $use_percona ? {
      true    => "${version}-${mongover[2]}.${facts['os']['distro']['codename']}",
      default => $version,
    }
  } else {
    $package_ensure        = true
    $package_ensure_mongos = true
  }

  # Amazon Linux's OS Family is 'Linux', operating system 'Amazon'.
  case $facts['os']['family'] {
    'RedHat', 'Linux', 'Suse': {
      if $manage_package {
        $user                    = pick($mongodb::globals::user, 'mongod')
        $group                   = pick($mongodb::globals::group, 'mongod')
        $server_package_name        = $use_percona ? {
          true    => pick($mongodb::globals::server_package_name, 'percona-server-mongodb-server'),
          default => pick($mongodb::globals::server_package_name, "mongodb-${mongodb::globals::edition}-server"),
        }
        $server_package_name_remove = $use_percona ? {
          true    => pick($mongodb::globals::server_package_name, "mongodb-${mongodb::globals::edition}-server"),
          default => pick($mongodb::globals::server_package_name, 'percona-server-mongodb-server'),
        }
      } else {
        # RedHat/CentOS doesn't come with a prepacked mongodb
        # so we assume that you are using EPEL repository.
        $user                    = pick($mongodb::globals::user, 'mongodb')
        $group                   = pick($mongodb::globals::group, 'mongodb')
        $server_package_name     = pick($mongodb::globals::server_package_name, 'mongodb-server')
      }

      $service_name = pick($mongodb::globals::service_name, 'mongod')
      $logpath      = '/var/log/mongodb/mongod.log'
      $pidfilepath  = '/var/run/mongodb/mongod.pid'
      $config       = '/etc/mongod.conf'
      $fork         = true
      $journal      = true
    }
    'Debian': {
      if $manage_package {
        $service_name               = pick($mongodb::globals::service_name, 'mongod')
        $server_package_name        = $use_percona ? {
          true    => pick($mongodb::globals::server_package_name, 'percona-server-mongodb-server'),
          default => pick($mongodb::globals::server_package_name, "mongodb-${mongodb::globals::edition}-server"),
        }
        $server_package_name_remove = $use_percona ? {
          true    => pick($mongodb::globals::server_package_name, "mongodb-${mongodb::globals::edition}-server"),
          default => pick($mongodb::globals::server_package_name, 'percona-server-mongodb-server'),
        }
        $config                     = '/etc/mongod.conf'
        $pidfilepath                = pick($mongodb::globals::pidfilepath, '/var/run/mongod.pid')
      } else {
        $server_package_name = pick($mongodb::globals::server_package_name, 'mongodb-server')
        $service_name        = pick($mongodb::globals::service_name, 'mongodb')
        $config              = '/etc/mongodb.conf'
        $pidfilepath         = $mongodb::globals::pidfilepath
      }
      if $use_percona == true {
        $user                    = pick($mongodb::globals::user, 'mongod')
        $group                   = pick($mongodb::globals::group, 'mongod')
      } else {
        $user                    = pick($mongodb::globals::user, 'mongodb')
        $group                   = pick($mongodb::globals::group, 'mongodb')
      }
      $logpath                 = '/var/log/mongodb/mongodb.log'
      # avoid using fork because of the init scripts design
      $fork                    = undef
      $journal                 = undef
    }
    default: {
      fail("Osfamily ${facts['os']['family']} is not supported")
    }
  }
}
