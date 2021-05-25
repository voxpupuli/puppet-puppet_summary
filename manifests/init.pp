#
# @summary manage the puppet-summary deployment
#
# @param version the version that should be pulled from GitHub
# @param port port where the daemon should listen
# @param ip ip where the daemon should listen
# @param user username that should be created
# @param group groupname that should be created
# @param homedir home directory for the new user
# @param shell the new shell for the new user
#
# @see https://github.com/skx/puppet-summary
#
# @author Tim Meusel <tim@bastelfreak.de>
#
class puppet_summary (
  String[3] $version = '1.10',
  Stdlib::Port::Unprivileged $port = 4321,
  Stdlib::IP::Address::Nosubnet $ip = '127.0.0.1',
  String1[1] $user = 'puppet-summary',
  String1[1] $group = $user,
  Stdlib::Absolutepath $homedir = "/opt/${user}",
  Stdlib::Absolutepath $shell = '/sbin/nologin',
) {
  user { $user:
    ensure         => 'present',
    managehome     => true,
    purge_ssh_keys => true,
    system         => true,
    home           => $homedir,
    shell          => $shell,
  }
  group { $group:
    ensure => 'present',
    system => true,
  }
  archive { "${homedir}/puppet-summary-${version}":
    ensure  => 'present',
    extract => false,
    source  => "https://github.com/skx/puppet-summary/releases/download/release-${version}/puppet-summary-linux-amd64",
    user    => $user,
    group   => $group,
    notify  => Service['puppet-summary.service'],
  }
  file { '/usr/bin/puppet-summary':
    ensure  => 'file',
    source  => "/opt/puppet-summary/puppet-summary-${version}",
    mode    => '0755',
    require => Archive["/opt/puppet-summary/puppet-summary-${version}"],
  }
  $content = @("EOT")
# THIS FILE IS MANAGED BY PUPPET
[Unit]
Description=Puppet summary web interface
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/skx/puppet-summary

[Service]
User=puppet-summary
Group=puppet-summary
WorkingDirectory=${homedir}
PrivateTmp=true
ExecStart=/usr/bin/puppet-summary serve -host "${ip}" -port "${port}"

[Install]
WantedBy=multi-user.target
|-EOT

  systemd::unit_file { 'puppet-summary.service':
    content => $content,
    enable  => true,
    active  => true,
  }
}
