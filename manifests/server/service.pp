# PRIVATE CLASS: do not call directly
class mongodb::server::service {
  $ensure           = $mongodb::server::service_ensure
  $service_manage   = $mongodb::server::service_manage
  $service_enable   = $mongodb::server::service_enable
  $service_name     = $mongodb::server::service_name
  $service_provider = $mongodb::server::service_provider
  $service_status   = $mongodb::server::service_status
  $bind_ip          = $mongodb::server::bind_ip
  $port             = $mongodb::server::port
  $configsvr        = $mongodb::server::configsvr
  $shardsvr         = $mongodb::server::shardsvr
  $use_percona      = $mongodb::server::use_percona
  $user             = $mongodb::server::user
  $group            = $mongodb::server::group
  $logpath          = $mongodb::server::logpath

  if !$port {
    if $configsvr {
      $port_real = 27019
    } elsif $shardsvr {
      $port_real = 27018
    } else {
      $port_real = 27017
    }
  } else {
    $port_real = $port
  }

  if $bind_ip == '0.0.0.0' {
    $bind_ip_real = '127.0.0.1'
  } else {
    $bind_ip_real = $bind_ip
  }

  $service_ensure = $ensure ? {
    'absent'  => false,
    'purged'  => false,
    'stopped' => false,
    default   => true
  }

  if $service_manage {
    if $use_percona==true
    {
      file_line { '/lib/systemd/system/mongod.service':
          ensure => absent,
          path   => '/lib/systemd/system/mongod.service',
          line   => 'Type=forking',
          }
      -> file { "/var/log/mongodb/mongod.stderr":
          owner => $user,
          group => $group,
          mode  => '0644',
        }
      -> file { "/var/log/mongodb/mongod.stdout":
          owner => $user,
          group => $group,
          mode  => '0644',
        }
    } 
    
    service { 'mongodb':
      ensure    => $service_ensure,
      name      => $service_name,
      enable    => $service_enable,
      provider  => $service_provider,
      hasstatus => true,
      status    => $service_status,
    }

    if $service_ensure {
      mongodb_conn_validator { 'mongodb':
        server  => $bind_ip_real,
        port    => $port_real,
        timeout => '240',
        require => Service['mongodb'],
      }
    }
  }
}
