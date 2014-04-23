class transmission-daemon (
  $package_ensure               = present,
  $service_ensure               = running,
  $service_enable               = true,

  $bind_address                 = '0.0.0.0',
  $encryption                   = 1,	# 0=prefer unencrypted, 1=prefer encrypted, 2=require encrypted
  $lpd_enabled                  = false,

  $transmission_home            = '/var/lib/transmission-daemon',
  $download_dir                 = "${transmission_home}/downloads",
  $incomplete_dir               = "${transmission_home}/incomplete",
  $incomplete_dir_enabled       = false,

  $peer_socket_tos              = 'default',
  $peer_limit_global            = 240,
  $peer_limit_per_torrent       = 60,
  $peer_port                    = 51413,
  $peer_port_random_low         = 49152,
  $peer_port_random_high        = 65535,
  $peer_port_random_on_start    = false,

  $rpc_enabled                  = true,
  $rpc_bind_address             = '0.0.0.0',
  $rpc_port                     = 9091,

  $rpc_authentication_required  = true,
  $rpc_username                 = 'transmission',
  $rpc_password                 = 'transmission',  # unhashed
  $rpc_url                      = '/transmission/',
  $rpc_whitelist                = '127.0.0.1',
  $rpc_whitelist_enabled        = true,

  $speed_limit_down             = 100,
  $speed_limit_down_enabled     = false,
  $speed_limit_up               = 100,
  $speed_limit_up_enabled       = false,

  $alt_speed_down               = 50,
  $alt_speed_enabled            = false,
  $alt_speed_up                 = 50,
  $alt_speed_time_enabled       = false,
  $alt_speed_time_begin         = 540,  # 9am
  $alt_speed_time_end           = 1020, # 5pm
  $alt_speed_time_day           = 127,
  
  $start_added_torrents         = true,
  $watch_dir                    = '',
  $watch_dir_enabled            = false,
  $trash_original_torrent_files = false,

  $settings_file                = '/etc/transmission-daemon/settings.json',
)
{

  # Parameters:
  # https://trac.transmissionbt.com/wiki/EditConfigFiles

  # File and directory locations:
  # https://trac.transmissionbt.com/wiki/ConfigFiles#Locations

  package { 'transmission-daemon':
    ensure => $package_ensure,
  }

  service { 'transmission-daemon':
    enable     => $service_enable,
    ensure     => $service_ensure,
    hasrestart => true,
    hasstatus  => true,
  }

  file { [ $download_dir, $incomplete_dir ]:
    ensure  => directory,
    owner   => 'debian-transmission',
    group   => 'debian-transmission',
    require => Package['transmission-daemon'],
  }

  file { $settings_file:
    ensure  => file,
    mode    => '600',
    owner   => 'debian-transmission',
    group   => 'debian-transmission',
    content => template('transmission-daemon/settings.json.erb'),
  }

  exec { 'refresh-transmission-daemon':
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => 'service transmission-daemon reload',
    subscribe   => File[$settings_file],
    refreshonly => true,
  }

}
