# Class for installing a MongoDB client shell (CLI).
#
# == Parameters
#
# $ensure:: Desired ensure state of the package.
#
# $package_name:: Name of the package to install the client from. Default is
#                 repository dependent.
#
class mongodb::client (
  String[1] $ensure = $mongodb::client::params::package_ensure,
  String[1] $package_name = $mongodb::client::params::package_name,
  String[1] $package_name_remove = $mongodb::client::params::package_name_remove,
) inherits mongodb::client::params {
  package { 'mongodb_client_removal':
    ensure => absent,
    name   => $package_name_remove,
    tag    => 'mongodb_package',
  }
  -> package { 'mongodb_client':
    ensure => $ensure,
    name   => $package_name,
    tag    => 'mongodb_package',
  }
}
